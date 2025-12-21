import axios from '../api/axios';

const getAllMedicalActs = async () => {
    const response = await axios.get('/medical-acts');
    return response.data;
};

const createMedicalAct = async (medicalAct) => {
    const response = await axios.post('/medical-acts', medicalAct);
    return response.data;
};

const updateMedicalAct = async (id, medicalAct) => {
    const response = await axios.put(`/medical-acts/${id}`, medicalAct);
    return response.data;
};

const deleteMedicalAct = async (id) => {
    await axios.delete(`/medical-acts/${id}`);
};

export default {
    getAllMedicalActs,
    createMedicalAct,
    updateMedicalAct,
    deleteMedicalAct
};
