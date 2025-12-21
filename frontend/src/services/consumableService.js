import axios from '../api/axios';

const getAllConsumables = async () => {
    const response = await axios.get('/consumables');
    return response.data;
};

const createConsumable = async (consumable) => {
    const response = await axios.post('/consumables', consumable);
    return response.data;
};

const updateConsumable = async (id, consumable) => {
    const response = await axios.put(`/consumables/${id}`, consumable);
    return response.data;
};

const deleteConsumable = async (id) => {
    await axios.delete(`/consumables/${id}`);
};

export default {
    getAllConsumables,
    createConsumable,
    updateConsumable,
    deleteConsumable
};
