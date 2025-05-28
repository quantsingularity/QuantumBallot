# Chainocracy Documentation

This directory contains the official documentation for the Chainocracy project, a full-stack Web and Mobile application for American elections using Blockchain Technology. The documentation is built using Sphinx, a powerful documentation generation tool that uses reStructuredText as its markup language.

## Overview

The documentation in this directory provides comprehensive information about the Chainocracy system, including setup instructions, configuration details, and usage guides. It is designed to be a central resource for developers, administrators, and users of the Chainocracy platform.

## Structure

The documentation is organized as follows:

- `conf.py`: Configuration file for Sphinx documentation generation
- `index.rst`: Main entry point for the documentation, containing the root table of contents
- `Makefile` and `make.bat`: Build scripts for generating documentation on Unix/Linux and Windows systems
- `sections/`: Directory containing the actual documentation content organized by topic
  - `dev/`: Development-related documentation
    - `setup_and_requirements.rst`: System requirements and setup instructions
    - `establish_network_center.rst`: Network center configuration
    - `installation_and_setup.rst`: Detailed installation procedures
    - `backend_and_frontend.rst`: Backend and frontend development documentation
- `images/`: Directory containing images used throughout the documentation
- `requirements.txt`: Python dependencies required for building the documentation

## Building the Documentation

To build the documentation locally:

1. Ensure you have Python installed on your system
2. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```
3. Build the HTML documentation:
   ```
   make html
   ```
   or on Windows:
   ```
   make.bat html
   ```
4. The generated documentation will be available in the `_build/html` directory

## Documentation Content

The documentation covers several key aspects of the Chainocracy system:

- System requirements and compatibility information for both mobile and web platforms
- Network requirements for optimal performance
- Setup and installation procedures for development and production environments
- Backend API documentation and integration guides
- Frontend development guidelines for both web and mobile interfaces
- Blockchain integration and configuration details
- User guides for committee members, voters, and system administrators

## Contributing to Documentation

When contributing to the documentation:

1. Use reStructuredText (.rst) format for all documentation files
2. Place images in the `images/` directory and reference them relatively
3. Update the table of contents in `index.rst` when adding new sections
4. Follow the existing structure and style for consistency
5. Build and test documentation locally before submitting changes

## Related Resources

- Video demonstrations of the system are available at: [Chainocracy YouTube Playlist](https://www.youtube.com/playlist?list=PL3FCe9r4avxF5OAZdxIAxMeC3--3c6OwU)
- For more detailed technical documentation, refer to the `documentation` directory at the root of the repository
