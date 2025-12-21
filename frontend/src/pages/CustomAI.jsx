import React, { useState, useEffect, useRef } from 'react';
import { Box, Paper, Typography, TextField, IconButton, Stack, Avatar } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import SmartToyIcon from '@mui/icons-material/SmartToy';
import PersonIcon from '@mui/icons-material/Person';
import axios from '../api/axios';

const CustomAI = () => {
    const [messages, setMessages] = useState([
        { id: 1, text: "Bonjour ! Je suis votre assistant médical. Comment puis-je vous aider aujourd'hui ?", sender: 'ai' }
    ]);
    const [input, setInput] = useState('');
    const [loading, setLoading] = useState(false);

    const messagesEndRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSend = async () => {
        if (!input.trim()) return;

        const userMessage = { id: Date.now(), text: input, sender: 'user' };
        setMessages(prev => [...prev, userMessage]);
        setInput('');
        setLoading(true);

        try {
            const response = await axios.post('/custom-ai/ask', { question: userMessage.text });
            const aiMessage = { id: Date.now() + 1, text: response.data.answer, sender: 'ai' };
            setMessages(prev => [...prev, aiMessage]);
        } catch (error) {
            console.error("Error sending message:", error);
            // Check if error response comes from backend logic (CustomAIController returns generic error map on exception? No, service catches it.)
            // The service returns the error string as the "answer".
            // So if axios fails (e.g. network error), we handle it here.

            const errorMessage = {
                id: Date.now() + 1,
                text: "Désolé, une erreur de communication est survenue.",
                sender: 'ai',
                isError: true
            };
            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setLoading(false);
        }
    };

    return (
        <Box sx={{ height: 'calc(100vh - 100px)', display: 'flex', flexDirection: 'column', gap: 2 }}>
            <Box sx={{ mb: 2 }}>
                <Typography variant="h4" sx={{ fontWeight: 800, color: '#1E293B', mb: 0.5 }}>
                    Assistant AI
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    Propulsé par OpenAI
                </Typography>
            </Box>

            <Paper sx={{ flex: 1, display: 'flex', flexDirection: 'column', borderRadius: 4, overflow: 'hidden', boxShadow: '0px 4px 20px rgba(0,0,0,0.05)' }}>
                <Box sx={{ flex: 1, p: 3, overflowY: 'auto', bgcolor: '#F8FAFC', display: 'flex', flexDirection: 'column', gap: 2 }}>
                    {messages.map((msg) => (
                        <Box
                            key={msg.id}
                            sx={{
                                alignSelf: msg.sender === 'user' ? 'flex-end' : 'flex-start',
                                maxWidth: '70%',
                                display: 'flex',
                                gap: 2,
                                flexDirection: msg.sender === 'user' ? 'row-reverse' : 'row'
                            }}
                        >
                            <Avatar sx={{ bgcolor: msg.sender === 'user' ? '#1E293B' : '#6366F1', width: 32, height: 32 }}>
                                {msg.sender === 'user' ? <PersonIcon fontSize="small" /> : <SmartToyIcon fontSize="small" />}
                            </Avatar>
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 2,
                                    borderRadius: 3,
                                    bgcolor: msg.sender === 'user' ? '#1E293B' : 'white',
                                    color: msg.sender === 'user' ? 'white' : 'text.primary',
                                    borderTopRightRadius: msg.sender === 'user' ? 0 : 12,
                                    borderTopLeftRadius: msg.sender === 'ai' ? 0 : 12,
                                    boxShadow: msg.sender === 'ai' ? '0px 2px 4px rgba(0,0,0,0.05)' : 'none'
                                }}
                            >
                                <Typography variant="body1" color={msg.isError ? 'error' : 'inherit'}>
                                    {msg.text}
                                </Typography>
                            </Paper>
                        </Box>
                    ))}
                    {loading && (
                        <Box sx={{ alignSelf: 'flex-start', maxWidth: '70%', display: 'flex', gap: 2 }}>
                            <Avatar sx={{ bgcolor: '#6366F1', width: 32, height: 32 }}>
                                <SmartToyIcon fontSize="small" />
                            </Avatar>
                            <Paper elevation={0} sx={{ p: 2, borderRadius: 3, bgcolor: 'white', borderTopLeftRadius: 0 }}>
                                <Typography variant="body2" color="text.secondary">Écriture en cours...</Typography>
                            </Paper>
                        </Box>
                    )}
                    <div ref={messagesEndRef} />
                </Box>

                <Box sx={{ p: 2, bgcolor: 'white', borderTop: '1px solid #E2E8F0' }}>
                    <Stack direction="row" spacing={2}>
                        <TextField
                            fullWidth
                            placeholder="Posez votre question..."
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                            disabled={loading}
                            sx={{
                                '& .MuiOutlinedInput-root': {
                                    borderRadius: 3,
                                    bgcolor: '#F8FAFC'
                                }
                            }}
                        />
                        <IconButton
                            onClick={handleSend}
                            disabled={!input.trim() || loading}
                            sx={{
                                bgcolor: '#6366F1',
                                color: 'white',
                                width: 56,
                                height: 56,
                                borderRadius: 3,
                                '&:hover': { bgcolor: '#4F46E5' },
                                '&.Mui-disabled': { bgcolor: '#E2E8F0', color: '#94A3B8' }
                            }}
                        >
                            <SendIcon />
                        </IconButton>
                    </Stack>
                </Box>
            </Paper>
        </Box>
    );
};

export default CustomAI;
