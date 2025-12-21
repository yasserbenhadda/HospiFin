import axios from 'axios';

const API_URL = 'http://localhost:8080/api/personnel';

const settingsService = {
    getCurrentProfile: async () => {
        try {
            const response = await axios.get(`${API_URL}/current`);
            return response.data;
        } catch (error) {
            console.error("Error fetching current profile:", error);
            throw error;
        }
    },

    updateProfile: async (id, profileData) => {
        try {
            const response = await axios.put(`${API_URL}/${id}`, profileData);
            return response.data;
        } catch (error) {
            console.error("Error updating profile:", error);
            throw error;
        }
    }
};

export default settingsService;
