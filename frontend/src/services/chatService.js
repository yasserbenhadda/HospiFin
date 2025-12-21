import axios from 'axios';

const API_URL = 'http://localhost:8080/api';

const chatService = {
    sendMessage: async (message) => {
        const response = await axios.post(`${API_URL}/chat`, { message });
        return response.data.response;
    }
};

export default chatService;
