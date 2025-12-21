import React, { useState, useEffect } from 'react';
import { Box, Typography, Paper, Button, Stack, Grid, LinearProgress, Tooltip as MuiTooltip } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import WarningIcon from '@mui/icons-material/Warning';
import InsightsIcon from '@mui/icons-material/Insights';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';

import forecastService from '../services/forecastService';

const Forecasts = () => {
    const [period, setPeriod] = useState(30);
    const [loading, setLoading] = useState(true);
    const [data, setData] = useState(null);

    useEffect(() => {
        const fetchForecasts = async () => {
            setLoading(true);
            try {
                const result = await forecastService.getForecasts(period);
                setData(result);
            } catch (error) {
                console.error("Error fetching forecasts:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchForecasts();
    }, [period]);

    if (loading) return <LinearProgress />;

    // --- Data Preparation ---
    const chartData = data?.globalHistory?.map((item) => {
        // Backend key is 'month', but for daily it holds "YYYY-MM-DD"
        // We parse it to show readable date
        const dateObj = new Date(item.month);
        const label = isNaN(dateObj.getTime()) ? item.month : dateObj.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' });
        return {
            name: label,
            // Uses Real Cost for history, falls back to Predicted for future (where real is undefined)
            value: item.real !== undefined ? item.real : item.predicted
        };
    }) || [];

    const totalPrediction = data?.globalPrediction || 0;
    const lowerConfidence = Math.round(totalPrediction * 0.92);
    const upperConfidence = Math.round(totalPrediction * 1.08);

    const services = [
        { name: 'Actes Médicaux', originalName: 'Actes Médicaux', data: data?.medicalActs },
        { name: 'Consommables', originalName: 'Consommables', data: data?.consumables },
        { name: 'Séjours', originalName: 'Séjours', data: data?.stays }
    ];

    // Find the max predicted value to normalize the progress bars
    const maxPredicted = Math.max(...services.map(s => s.data?.predictedTotal || 0));

    const servicesWithTrend = services.map(s => {
        // SMART LOGIC: Compare "Predicted Total (Next N Days)" vs "Historic Real Total (Last N Days)"

        let baseline = 0;

        // Calculate REAL sum from history
        if (s.data?.history?.length > 0) {
            // Filter out FUTURE predictions (isPrediction property) if we added that flag in backend
            // But wait, the backend adds them with 'isPrediction' flag or just appends.
            // If we want "Last N Days", we should exclude the "Future" points we just added.

            // The history list now contains: [Past Points] + [Future Points].
            // To get "Last Period Real", we need to sum only the Past Points.
            // In backend Step 3, we build history. In Step 4 we append future.

            // We can check item.isPrediction property if it exists (I added it in backend).
            // OR checks dates.

            baseline = s.data.history.reduce((acc, item) => {
                if (item.isPrediction) return acc; // Skip future points
                return acc + (item.real || item.cost || 0);
            }, 0);
        }

        const predicted = s.data?.predictedTotal || 0;

        const diff = predicted - baseline;
        const percent = baseline !== 0 ? (diff / baseline) * 100 : 0;

        // 1. Trend Color:
        let badgeColor = '#1E293B'; // Default Dark
        if (percent > 5) badgeColor = '#EF4444'; // Red (Growth alarm)
        else if (percent < 0) badgeColor = '#10B981'; // Green (Savings)

        // 2. Bar Scale (Relative Impact):
        const scale = maxPredicted !== 0 ? (predicted / maxPredicted) * 100 : 0;

        return {
            name: s.name,
            current: baseline, // Now this is Total Real Last Period
            predicted,
            trend: percent,
            scale: scale,
            badgeColor
        };
    });

    return (
        <Box sx={{ pb: 4, maxWidth: 1200, mx: 'auto' }}>
            {/* Page Header */}
            <Box sx={{ mb: 4 }}>
                <Typography variant="h5" fontWeight={700} color="#1E293B" gutterBottom>
                    Prévisions des coûts
                </Typography>
                <Typography variant="body2" color="#64748B">
                    Anticipez les dépenses futures basées sur l'analyse prédictive
                </Typography>
            </Box>

            {/* Period Selector */}
            <Paper elevation={0} sx={{ p: 0.5, mb: 4, borderRadius: 2, bgcolor: 'transparent', display: 'flex', gap: 1 }}>
                <Typography variant="body2" sx={{ display: 'flex', alignItems: 'center', mr: 2, fontWeight: 500, color: '#64748B' }}>
                    Période de prévision :
                </Typography>
                {[30, 60, 90].map((days) => (
                    <Button
                        key={days}
                        onClick={() => setPeriod(days)}
                        variant="contained"
                        disableElevation
                        sx={{
                            borderRadius: 2,
                            textTransform: 'none',
                            bgcolor: period === days ? '#1E293B' : '#F1F5F9',
                            color: period === days ? 'white' : '#64748B',
                            fontWeight: 600,
                            fontSize: '0.875rem',
                            px: 3,
                            '&:hover': { bgcolor: period === days ? '#0F172A' : '#E2E8F0' }
                        }}
                    >
                        {days} jours
                    </Button>
                ))}
            </Paper>

            {/* Main Hero Card */}
            <Paper
                elevation={0}
                sx={{
                    p: 4,
                    borderRadius: 3,
                    mb: 4,
                    background: 'linear-gradient(135deg, #0E7490 0%, #06B6D4 100%)',
                    color: 'white',
                    position: 'relative',
                    overflow: 'hidden',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
                }}
            >
                <Box sx={{ position: 'absolute', top: 24, right: 24, p: 1, bgcolor: 'rgba(255,255,255,0.2)', borderRadius: 1.5 }}>
                    <TrendingUpIcon sx={{ color: 'white' }} />
                </Box>

                <Stack spacing={0.5} mb={3}>
                    <Stack direction="row" alignItems="center" spacing={1}>
                        <Box sx={{ p: 0.5, border: '2px solid rgba(255,255,255,0.5)', borderRadius: '50%', width: 20, height: 20, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                            <Box sx={{ width: 8, height: 8, bgcolor: 'white', borderRadius: '50%' }} />
                        </Box>
                        <Typography variant="h6" fontWeight={600} sx={{ opacity: 0.9 }}>
                            Prévision totale ({period} jours)
                        </Typography>
                    </Stack>
                </Stack>

                <Typography variant="h2" fontWeight={700} sx={{ mb: 1, letterSpacing: '-1px' }}>
                    {totalPrediction.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 })}
                </Typography>

                <Typography variant="body2" sx={{ opacity: 0.8, mb: 4, fontWeight: 500 }}>
                    Estimation basée sur la tendance linéaire historique
                </Typography>

                <Box sx={{ bgcolor: 'rgba(0,0,0,0.1)', p: 2, borderRadius: 1, borderLeft: '4px solid rgba(255,255,255,0.3)' }}>
                    <Typography variant="caption" sx={{ opacity: 0.9, lineHeight: 1.5 }}>
                        Note : Cette prévision est une projection mathématique basée sur vos données passées.
                    </Typography>
                </Box>
            </Paper>

            {/* Chart Section */}
            <Paper elevation={0} sx={{ p: 3, borderRadius: 3, mb: 4, bgcolor: 'white', border: '1px solid #E2E8F0' }}>
                <Box sx={{ mb: 3 }}>
                    <Typography variant="h6" fontWeight={700} color="#1E293B">
                        Projection des coûts futurs
                    </Typography>
                    <Typography variant="body2" color="#64748B">
                        Évolution prévue par semaine
                    </Typography>
                </Box>

                <Box sx={{ height: 300, width: '100%' }}>
                    <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                            <XAxis
                                dataKey="name"
                                axisLine={false}
                                tickLine={false}
                                tick={{ fontSize: 12, fill: '#64748B' }}
                                dy={10}
                            />
                            <YAxis
                                axisLine={false}
                                tickLine={false}
                                tick={{ fontSize: 12, fill: '#64748B' }}
                                tickFormatter={(val) => `${val / 1000}k€`}
                            />
                            <Tooltip
                                contentStyle={{ borderRadius: 8, border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }}
                                formatter={(value) => [value.toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' €', 'Coût']}
                            />
                            <Line
                                type="monotone"
                                dataKey="value"
                                stroke="#1E293B"
                                strokeWidth={2}
                                dot={false}
                                activeDot={{ r: 6, strokeWidth: 0 }}
                            />
                        </LineChart>
                    </ResponsiveContainer>
                </Box>
            </Paper>

            {/* Service Breakdown List */}
            <Box sx={{ mb: 4 }}>
                <Stack direction="row" justifyContent="space-between" alignItems="center" mb={3}>
                    <Box>
                        <Typography variant="h6" fontWeight={700} color="#1E293B">
                            Prévisions par service
                        </Typography>
                        <Typography variant="body2" color="#64748B">
                            Comparaison : Réel passé vs Prévision future
                        </Typography>
                    </Box>
                    <MuiTooltip title="Le badge indique le % de croissance future par rapport à la moyenne. La barre indique le poids budgétaire.">
                        <InfoOutlinedIcon color="action" />
                    </MuiTooltip>
                </Stack>

                <Paper elevation={0} sx={{ borderRadius: 3, border: '1px solid #E2E8F0', overflow: 'hidden' }}>
                    {servicesWithTrend.map((service, index) => (
                        <Box key={service.name} sx={{ p: 3, borderBottom: index !== servicesWithTrend.length - 1 ? '1px solid #E2E8F0' : 'none' }}>
                            <Grid container alignItems="center" spacing={2}>
                                {/* Service Name & Trend Badge */}
                                <Grid item xs={12} sm={3}>
                                    <Stack direction="row" alignItems="center" spacing={1}>
                                        <Typography variant="subtitle1" fontWeight={600} color="#1E293B">
                                            {service.name}
                                        </Typography>
                                        <Box sx={{
                                            bgcolor: service.badgeColor,
                                            color: 'white',
                                            fontSize: '0.7rem',
                                            fontWeight: 700,
                                            px: 1,
                                            py: 0.2,
                                            borderRadius: 4
                                        }}>
                                            {service.trend > 0 ? '+' : ''}{service.trend.toFixed(1)}%
                                        </Box>
                                    </Stack>
                                    <Stack direction="row" spacing={1} mt={0.5}>
                                        <Typography variant="caption" color="#64748B">
                                            Total Réel ({period}j): <span style={{ fontWeight: 600, color: '#334155' }}>{service.current.toLocaleString(undefined, { maximumFractionDigits: 0 })} €</span>
                                        </Typography>
                                        <Typography variant="caption" color="#64748B">
                                            Prévu: <span style={{ fontWeight: 600, color: '#334155' }}>{service.predicted.toLocaleString(undefined, { maximumFractionDigits: 0 })} €</span>
                                        </Typography>
                                    </Stack>
                                </Grid>

                                {/* Progress Bar */}
                                <Grid item xs={12} sm={9}>
                                    <Box sx={{ width: '100%', display: 'flex', alignItems: 'center' }}>
                                        <Box sx={{ flexGrow: 1, mr: 2 }}>
                                            <MuiTooltip title={`Poids financier relatif: ${service.scale.toFixed(1)}% du service le plus coûteux`}>
                                                <LinearProgress
                                                    variant="determinate"
                                                    value={service.scale}
                                                    sx={{
                                                        height: 8,
                                                        borderRadius: 4,
                                                        bgcolor: '#F1F5F9',
                                                        '& .MuiLinearProgress-bar': {
                                                            bgcolor: index === 0 ? '#1E293B' : (index === 1 ? '#F59E0B' : '#8B5CF6'), // Distinct colors for visual clarity
                                                            borderRadius: 4
                                                        }
                                                    }}
                                                />
                                            </MuiTooltip>
                                        </Box>
                                    </Box>
                                </Grid>
                            </Grid>
                        </Box>
                    ))}
                </Paper>
            </Box>

            {/* Bottom Insights Cards */}
            <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                    <Paper elevation={0} sx={{ p: 3, borderRadius: 3, bgcolor: '#ECFDF5', border: '1px solid #D1FAE5' }}>
                        <Stack direction="row" spacing={2} mb={1}>
                            <Box sx={{ p: 1, bgcolor: '#10B981', borderRadius: 1.5, color: 'white', display: 'flex' }}>
                                <TrendingUpIcon fontSize="small" />
                            </Box>
                            <Box>
                                <Typography variant="h6" fontWeight={700} color="#064E3B">
                                    Augmentation prévue
                                </Typography>
                            </Box>
                        </Stack>
                        <Typography variant="body2" color="#065F46" sx={{ mb: 2, lineHeight: 1.6 }}>
                            Le service <b>{servicesWithTrend[0]?.name}</b> porte la plus grande part du budget ({servicesWithTrend[0]?.scale.toFixed(0)}% du max). Surveillez ce poste.
                        </Typography>
                        <Button variant="text" sx={{ color: '#059669', fontWeight: 600, textTransform: 'none', p: 0, '&:hover': { bgcolor: 'transparent', textDecoration: 'underline' } }}>
                            Analyser les causes
                        </Button>
                    </Paper>
                </Grid>

                <Grid item xs={12} md={6}>
                    <Paper elevation={0} sx={{ p: 3, borderRadius: 3, bgcolor: '#FFF7ED', border: '1px solid #FFEDD5' }}>
                        <Stack direction="row" spacing={2} mb={1}>
                            <Box sx={{ p: 1, bgcolor: '#F97316', borderRadius: 1.5, color: 'white', display: 'flex' }}>
                                <WarningIcon fontSize="small" />
                            </Box>
                            <Box>
                                <Typography variant="h6" fontWeight={700} color="#7C2D12">
                                    Points d'attention
                                </Typography>
                            </Box>
                        </Stack>
                        <Typography variant="body2" color="#9A3412" sx={{ mb: 2, lineHeight: 1.6 }}>
                            Le ratio coûts de personnel augmente de manière significative. Une optimisation des plannings pourrait permettre de réduire ces dépenses.
                        </Typography>
                        <Button variant="text" sx={{ color: '#C2410C', fontWeight: 600, textTransform: 'none', p: 0, '&:hover': { bgcolor: 'transparent', textDecoration: 'underline' } }}>
                            Voir les recommandations
                        </Button>
                    </Paper>
                </Grid>
            </Grid>
        </Box>
    );
};

export default Forecasts;
