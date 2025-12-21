import axios from '../api/axios';

const getAllPatients = async () => {
    const response = await axios.get('/patients');
    return response.data;
};

const createPatient = async (patient) => {
    const response = await axios.post('/patients', patient);
    return response.data;
};

const updatePatient = async (id, patient) => {
    const response = await axios.put(`/patients/${id}`, patient);
    return response.data;
};

const deletePatient = async (id) => {
    await axios.delete(`/patients/${id}`);
};

export default {
    getAllPatients,
    createPatient,
    updatePatient,
    deletePatient
};
