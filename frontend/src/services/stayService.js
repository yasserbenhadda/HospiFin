import axios from '../api/axios';

const getAllStays = async () => {
    const response = await axios.get('/stays');
    return response.data;
};

const createStay = async (stay) => {
    const response = await axios.post('/stays', stay);
    return response.data;
};

const updateStay = async (id, stay) => {
    const response = await axios.put(`/stays/${id}`, stay);
    return response.data;
};

const deleteStay = async (id) => {
    await axios.delete(`/stays/${id}`);
};

export default {
    getAllStays,
    createStay,
    updateStay,
    deleteStay
};
