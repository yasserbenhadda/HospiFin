import axios from '../api/axios';

const getAllPersonnel = async () => {
    const response = await axios.get('/personnel');
    return response.data;
};

const createPersonnel = async (personnel) => {
    const response = await axios.post('/personnel', personnel);
    return response.data;
};

const updatePersonnel = async (id, personnel) => {
    const response = await axios.put(`/personnel/${id}`, personnel);
    return response.data;
};

const deletePersonnel = async (id) => {
    await axios.delete(`/personnel/${id}`);
};

export default {
    getAllPersonnel,
    createPersonnel,
    updatePersonnel,
    deletePersonnel
};
