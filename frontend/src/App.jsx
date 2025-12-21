import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import theme from './theme';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Patients from './pages/Patients';
import Stays from './pages/Stays';
import MedicalActs from './pages/MedicalActs';
import Medications from './pages/Medications';
import Consumables from './pages/Consumables';
import Personnel from './pages/Personnel';
import Forecasts from './pages/Forecasts';
import Settings from './pages/Settings';

import CustomAI from './pages/CustomAI';
import ChatAssistant from './pages/ChatAssistant';
function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Layout>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/patients" element={<Patients />} />
            <Route path="/stays" element={<Stays />} />
            <Route path="/medical-acts" element={<MedicalActs />} />
            <Route path="/medications" element={<Medications />} />
            <Route path="/consumables" element={<Consumables />} />
            <Route path="/personnel" element={<Personnel />} />
            <Route path="/forecasts" element={<Forecasts />} />
            <Route path="/settings" element={<Settings />} />
            <Route path="/custom-ai" element={<CustomAI />} />
            <Route path="/chat" element={<ChatAssistant />} />
          </Routes>
        </Layout>
      </Router>
    </ThemeProvider>
  );
}

export default App;
