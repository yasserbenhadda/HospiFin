import React, { useState, useRef, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import { Box, Typography, Paper, TextField, IconButton, Stack, Avatar, CircularProgress } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import SmartToyIcon from '@mui/icons-material/SmartToy';
import PersonIcon from '@mui/icons-material/Person';
import chatService from '../services/chatService';

const ChatAssistant = () => {
    const [messages, setMessages] = useState([
        {
            content: 'Bonjour ! Je suis l\'assistant HospiFin. Je suis expert en coûts hospitaliers et prévisions, mais je peux aussi répondre à vos questions générales. Comment puis-je vous aider ?'
        }
    ]);
    const [input, setInput] = useState('');
    const [loading, setLoading] = useState(false);
    const messagesEndRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSend = async () => {
        if (!input.trim() || loading) return;

        const userMessage = input.trim();
        setInput('');
        setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
        setLoading(true);

        try {
            const response = await chatService.sendMessage(userMessage);
            setMessages(prev => [...prev, { role: 'assistant', content: response }]);
        } catch (error) {
            setMessages(prev => [...prev, {
                role: 'assistant',
                content: 'Désolé, une erreur s\'est produite. Veuillez réessayer.'
            }]);
        } finally {
            setLoading(false);
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend();
        }
    };

    return (
        <Box sx={{
            height: 'calc(100vh - 100px)',
            display: 'flex',
            flexDirection: 'column',
            maxWidth: 900,
            mx: 'auto'
        }}>
            {/* Header */}
            <Paper elevation={0} sx={{ p: 3, mb: 2, borderRadius: 3, bgcolor: 'white', border: '1px solid #E2E8F0' }}>
                <Stack direction="row" alignItems="center" spacing={2}>
                    <Box sx={{
                        p: 1.5,
                        borderRadius: 2,
                        background: 'linear-gradient(135deg, #0EA5E9 0%, #14B8A6 100%)',
                        color: 'white'
                    }}>
                        <SmartToyIcon />
                    </Box>
                    <Box>
                        <Typography variant="h6" fontWeight={700} color="#1E293B">
                            Assistant IA HospiFin
                        </Typography>
                        <Typography variant="body2" color="#64748B">
                            Posez vos questions sur le tableau de bord ou autre
                        </Typography>
                    </Box>
                </Stack>
            </Paper>

            {/* Messages Area */}
            <Paper
                elevation={0}
                sx={{
                    flex: 1,
                    p: 3,
                    borderRadius: 3,
                    bgcolor: '#F8FAFC',
                    border: '1px solid #E2E8F0',
                    overflow: 'auto',
                    mb: 2
                }}
            >
                <Stack spacing={2}>
                    {messages.map((msg, index) => (
                        <Stack
                            key={index}
                            direction="row"
                            spacing={1.5}
                            justifyContent={msg.role === 'user' ? 'flex-end' : 'flex-start'}
                        >
                            {msg.role === 'assistant' && (
                                <Avatar sx={{
                                    bgcolor: '#0EA5E9',
                                    width: 36,
                                    height: 36
                                }}>
                                    <SmartToyIcon sx={{ fontSize: 20 }} />
                                </Avatar>
                            )}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 2,
                                    maxWidth: '70%',
                                    borderRadius: 2,
                                    bgcolor: msg.role === 'user' ? '#1E293B' : 'white',
                                    color: msg.role === 'user' ? 'white' : '#1E293B',
                                    border: msg.role === 'user' ? 'none' : '1px solid #E2E8F0'
                                }}
                            >
                                <Box sx={{
                                    fontSize: '0.875rem',
                                    lineHeight: 1.6,
                                    '& p': { m: 0, mb: 1 },
                                    '& p:last-child': { mb: 0 }
                                }}>
                                    <ReactMarkdown
                                        components={{
                                            code({ node, inline, className, children, ...props }) {
                                                const match = /language-(\w+)/.exec(className || '');
                                                return !inline ? (
                                                    <Box
                                                        component="pre"
                                                        sx={{
                                                            bgcolor: '#0F172A',
                                                            color: '#F8FAFC',
                                                            p: 2,
                                                            borderRadius: 2,
                                                            overflow: 'auto',
                                                            fontSize: '0.875rem',
                                                            my: 1.5,
                                                            fontFamily: 'monospace'
                                                        }}
                                                    >
                                                        <code className={className} {...props}>
                                                            {children}
                                                        </code>
                                                    </Box>
                                                ) : (
                                                    <code className={className} {...props} style={{ backgroundColor: 'rgba(0,0,0,0.1)', padding: '2px 4px', borderRadius: 4, fontFamily: 'monospace' }}>
                                                        {children}
                                                    </code>
                                                );
                                            }
                                        }}
                                    >
                                        {msg.content}
                                    </ReactMarkdown>
                                </Box>
                            </Paper>
                            {msg.role === 'user' && (
                                <Avatar sx={{
                                    bgcolor: '#64748B',
                                    width: 36,
                                    height: 36
                                }}>
                                    <PersonIcon sx={{ fontSize: 20 }} />
                                </Avatar>
                            )}
                        </Stack>
                    ))}
                    {loading && (
                        <Stack direction="row" spacing={1.5}>
                            <Avatar sx={{ bgcolor: '#0EA5E9', width: 36, height: 36 }}>
                                <SmartToyIcon sx={{ fontSize: 20 }} />
                            </Avatar>
                            <Paper
                                elevation={0}
                                sx={{ p: 2, borderRadius: 2, bgcolor: 'white', border: '1px solid #E2E8F0' }}
                            >
                                <CircularProgress size={20} sx={{ color: '#0EA5E9' }} />
                            </Paper>
                        </Stack>
                    )}
                    <div ref={messagesEndRef} />
                </Stack>
            </Paper>

            {/* Input Area */}
            <Paper
                elevation={0}
                sx={{
                    p: 2,
                    borderRadius: 3,
                    bgcolor: 'white',
                    border: '1px solid #E2E8F0',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 2
                }}
            >
                <TextField
                    fullWidth
                    multiline
                    maxRows={3}
                    placeholder="Posez votre question..."
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyPress={handleKeyPress}
                    disabled={loading}
                    sx={{
                        '& .MuiOutlinedInput-root': {
                            borderRadius: 2,
                            bgcolor: '#F8FAFC',
                            '& fieldset': { borderColor: '#E2E8F0' },
                            '&:hover fieldset': { borderColor: '#CBD5E1' },
                            '&.Mui-focused fieldset': { borderColor: '#0EA5E9' }
                        }
                    }}
                />
                <IconButton
                    onClick={handleSend}
                    disabled={loading || !input.trim()}
                    sx={{
                        bgcolor: '#1E293B',
                        color: 'white',
                        p: 1.5,
                        '&:hover': { bgcolor: '#0F172A' },
                        '&.Mui-disabled': { bgcolor: '#E2E8F0', color: '#94A3B8' }
                    }}
                >
                    <SendIcon />
                </IconButton>
            </Paper>
        </Box>
    );
};

export default ChatAssistant;
