import axios from '../api/axios';

const getAllMedications = async () => {
    const response = await axios.get('/medications');
    return response.data;
};

const createMedication = async (medication) => {
    const response = await axios.post('/medications', medication);
    return response.data;
};

const updateMedication = async (id, medication) => {
    const response = await axios.put(`/medications/${id}`, medication);
    return response.data;
};

const deleteMedication = async (id) => {
    await axios.delete(`/medications/${id}`);
};

export default {
    getAllMedications,
    createMedication,
    updateMedication,
    deleteMedication
};
