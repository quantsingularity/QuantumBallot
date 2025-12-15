/**
 * Asset Loading Service
 * Manages candidate images and other assets
 * Replaces Firebase with direct API-based asset management
 */

import axios from "../api/axios";
import { Config } from "../constants/config";

/**
 * Load candidate images from the API or local assets
 * Returns a map of candidate codes to their image URIs
 */
export async function loadImages(): Promise<Record<string, any>> {
  try {
    // Attempt to fetch candidate images from the backend
    const response = await axios.get(Config.ENDPOINTS.CANDIDATES);

    if (response.data && response.data.candidates) {
      const imageMap: Record<string, any> = {};

      // Map candidates to their image URIs
      response.data.candidates.forEach((candidate: any) => {
        if (candidate.code && candidate.imageUrl) {
          imageMap[candidate.code.toString()] = {
            uri: candidate.imageUrl,
            code: candidate.code,
            name: candidate.name,
          };
        }
      });

      return imageMap;
    }

    return {};
  } catch (error) {
    if (Config.APP.SHOW_LOGS) {
      console.error("Error loading candidate images:", error);
    }
    // Return empty map on error - components should handle missing images gracefully
    return {};
  }
}

/**
 * Get image URI for a specific candidate by code
 */
export async function getCandidateImage(code: number): Promise<string | null> {
  try {
    const images = await loadImages();
    return images[code.toString()]?.uri || null;
  } catch (error) {
    if (Config.APP.SHOW_LOGS) {
      console.error(`Error loading image for candidate ${code}:`, error);
    }
    return null;
  }
}

/**
 * Load party/political organization logos
 */
export async function loadPartyLogos(): Promise<Record<string, string>> {
  try {
    // In a production system, this would fetch from an API endpoint
    // For now, return empty map - components will use fallback images
    return {};
  } catch (error) {
    if (Config.APP.SHOW_LOGS) {
      console.error("Error loading party logos:", error);
    }
    return {};
  }
}

// Export null implementations for backwards compatibility (if needed)
export const storage = null;
export const ref = () => null;
export const getDownloadURL = async () => "";
export const uploadBytes = async () => ({});
export const listAll = async () => ({ items: [] });
