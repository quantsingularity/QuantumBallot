# """
# AWS Lambda function for automatic secret rotation
# Implements secure password rotation for database credentials
# """

import json
import logging
import os

import boto3
import psycopg2
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
secrets_client = boto3.client("secretsmanager")
rds_client = boto3.client("rds")


def lambda_handler(event, context):
    #    """
    #    Main Lambda handler for secret rotation
    #    """
    try:
        # Extract secret ARN and token from event
        secret_arn = event["SecretId"]
        token = event["ClientRequestToken"]
        step = event["Step"]

        logger.info(f"Starting secret rotation for {secret_arn}, step: {step}")

        # Route to appropriate step handler
        if step == "createSecret":
            create_secret(secret_arn, token)
        elif step == "setSecret":
            set_secret(secret_arn, token)
        elif step == "testSecret":
            test_secret(secret_arn, token)
        elif step == "finishSecret":
            finish_secret(secret_arn, token)
        else:
            raise ValueError(f"Invalid step parameter: {step}")

        logger.info(f"Successfully completed step {step} for {secret_arn}")

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": f"Successfully completed {step}", "secretArn": secret_arn}
            ),
        }

    except Exception as e:
        logger.error(f"Error in secret rotation: {str(e)}")
        raise e


def create_secret(secret_arn, token):
    #    """
    #    Create a new secret version with a new password
    #    """
    try:
        # Get current secret
        current_secret = get_secret_dict(secret_arn, "AWSCURRENT")

        # Generate new password
        new_password = generate_password()

        # Create new secret version
        new_secret = current_secret.copy()
        new_secret["password"] = new_password

        # Put new secret version
        secrets_client.put_secret_value(
            SecretId=secret_arn,
            ClientRequestToken=token,
            SecretString=json.dumps(new_secret),
            VersionStage="AWSPENDING",
        )

        logger.info(f"Created new secret version for {secret_arn}")

    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceExistsException":
            logger.info(f"Secret version already exists for {secret_arn}")
        else:
            raise e


def set_secret(secret_arn, token):
    #    """
    #    Set the new password in the database
    #    """
    try:
        # Get current and pending secrets
        current_secret = get_secret_dict(secret_arn, "AWSCURRENT")
        pending_secret = get_secret_dict(secret_arn, "AWSPENDING", token)

        # Connect to database with current credentials
        connection = get_database_connection(current_secret)

        try:
            with connection.cursor() as cursor:
                # Update password for the user
                username = pending_secret["username"]
                new_password = pending_secret["password"]

                # Use parameterized query to prevent SQL injection
                cursor.execute(
                    "ALTER USER %s WITH PASSWORD %s", (username, new_password)
                )

                connection.commit()
                logger.info(f"Successfully updated password for user {username}")

        finally:
            connection.close()

    except Exception as e:
        logger.error(f"Error setting secret in database: {str(e)}")
        raise e


def test_secret(secret_arn, token):
    #    """
    #    Test the new password by connecting to the database
    #    """
    try:
        # Get pending secret
        pending_secret = get_secret_dict(secret_arn, "AWSPENDING", token)

        # Test connection with new credentials
        connection = get_database_connection(pending_secret)

        try:
            with connection.cursor() as cursor:
                # Simple test query
                cursor.execute("SELECT 1")
                result = cursor.fetchone()

                if result[0] != 1:
                    raise Exception("Test query failed")

                logger.info(f"Successfully tested new credentials for {secret_arn}")

        finally:
            connection.close()

    except Exception as e:
        logger.error(f"Error testing secret: {str(e)}")
        raise e


def finish_secret(secret_arn, token):
    #    """
    #    Finalize the rotation by updating version stages
    #    """
    try:
        # Move AWSPENDING to AWSCURRENT
        secrets_client.update_secret_version_stage(
            SecretId=secret_arn,
            VersionStage="AWSCURRENT",
            ClientRequestToken=token,
            RemoveFromVersionId=get_secret_version_id(secret_arn, "AWSCURRENT"),
        )

        logger.info(f"Successfully finished rotation for {secret_arn}")

    except Exception as e:
        logger.error(f"Error finishing secret rotation: {str(e)}")
        raise e


def get_secret_dict(secret_arn, stage, token=None):
    #    """
    #    Get secret as dictionary
    #    """
    try:
        kwargs = {"SecretId": secret_arn, "VersionStage": stage}

        if token:
            kwargs["VersionId"] = token

        response = secrets_client.get_secret_value(**kwargs)
        return json.loads(response["SecretString"])

    except Exception as e:
        logger.error(f"Error getting secret: {str(e)}")
        raise e


def get_secret_version_id(secret_arn, stage):
    #    """
    #    Get version ID for a specific stage
    #    """
    try:
        response = secrets_client.describe_secret(SecretId=secret_arn)

        for version_id, version_info in response["VersionIdsToStages"].items():
            if stage in version_info:
                return version_id

        raise Exception(f"Version stage {stage} not found")

    except Exception as e:
        logger.error(f"Error getting version ID: {str(e)}")
        raise e


def get_database_connection(secret_dict):
    #    """
    #    Create database connection using secret credentials
    #    """
    try:
        connection = psycopg2.connect(
            host=secret_dict["host"],
            port=secret_dict["port"],
            database=secret_dict["dbname"],
            user=secret_dict["username"],
            password=secret_dict["password"],
            sslmode="require",
            connect_timeout=10,
        )

        return connection

    except Exception as e:
        logger.error(f"Error connecting to database: {str(e)}")
        raise e


def generate_password():
    #    """
    #    Generate a secure random password
    #    """
    import secrets
    import string

    # Define character sets
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special_chars = "!@#$%^&*"

    # Ensure at least one character from each set
    password = [
        secrets.choice(lowercase),
        secrets.choice(uppercase),
        secrets.choice(digits),
        secrets.choice(special_chars),
    ]

    # Fill remaining length with random characters
    all_chars = lowercase + uppercase + digits + special_chars
    for _ in range(28):  # Total length 32
        password.append(secrets.choice(all_chars))

    # Shuffle the password
    secrets.SystemRandom().shuffle(password)

    return "".join(password)


def send_notification(message, secret_arn):
    #    """
    #    Send notification about rotation status
    #    """
    try:
        sns_client = boto3.client("sns")
        topic_arn = os.environ.get("SNS_TOPIC_ARN")

        if topic_arn:
            sns_client.publish(
                TopicArn=topic_arn,
                Subject=f"Secret Rotation Alert - {os.environ.get('environment', 'unknown')}",
                Message=f"Secret: {secret_arn}\nMessage: {message}",
            )

    except Exception as e:
        logger.error(f"Error sending notification: {str(e)}")
        # Don't raise exception for notification failures
