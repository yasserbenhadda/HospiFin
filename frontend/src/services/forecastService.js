import axios from '../api/axios';

const getForecasts = async (days = 30) => {
    const response = await axios.get(`/forecasts?days=${days}`);
    return response.data;
};

export default {
    getForecasts
};
