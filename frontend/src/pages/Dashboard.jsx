import React, { useState, useEffect } from 'react';
import {
    Box, Grid, Paper, Typography, Button, Stack, Chip, Avatar,
    List, ListItem, ListItemText, ListItemAvatar, Divider, IconButton
} from '@mui/material';
import {
    LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip,
    ResponsiveContainer, BarChart, Bar, PieChart, Pie, Cell, Legend
} from 'recharts';

// Icons
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import PeopleOutlineIcon from '@mui/icons-material/PeopleOutline';
import PercentIcon from '@mui/icons-material/Percent';
import EventIcon from '@mui/icons-material/Event';

// Services
import dashboardService from '../services/dashboardService';
import forecastService from '../services/forecastService';

const COLORS_PIE = ['#1E3A8A', '#14B8A6', '#60A5FA', '#F97316']; // Dark blue, Teal, Light blue, Orange

const Dashboard = () => {
    const [summary, setSummary] = useState(null);
    const [forecastData, setForecastData] = useState([]);
    const [loading, setLoading] = useState(true);

    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [summaryData, forecastResult] = await Promise.all([
                    dashboardService.getDashboardSummary(),
                    forecastService.getForecasts(30)
                ]);

                setSummary(summaryData);

                if (forecastResult.globalHistory) {
                    const chartData = forecastResult.globalHistory
                        .slice(-30)
                        .map(item => ({
                            name: item.month,
                            real: item.real,
                            predicted: item.predicted
                        }));
                    setForecastData(chartData);
                }
            } catch (err) {
                console.error("Dashboard data fetch failed:", err);
                setError(err.message || "Erreur inconnue");
                setSummary(null);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    if (loading) return <Box sx={{ p: 4 }}>Chargement...</Box>;

    const cardStyle = {
        p: 2.5,
        borderRadius: 3,
        bgcolor: 'white',
        boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        border: '1px solid #E2E8F0'
    };

    return (
        <Box sx={{ p: 3, bgcolor: '#F8FAFC', minHeight: '100vh', fontFamily: '"Inter", sans-serif', color: '#1E293B', width: '100%', boxSizing: 'border-box', overflowX: 'hidden' }}>

            {/* Overview Section */}
            <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={4}>
                <Box>
                    <Typography variant="h5" fontWeight={700} color="#0F172A" mb={0.5} sx={{ letterSpacing: '-0.5px' }}>
                        Vue d'ensemble
                    </Typography>
                </Box>
                <Stack direction="row" spacing={1.5}>
                    <Button
                        endIcon={<KeyboardArrowDownIcon sx={{ fontSize: 18 }} />}
                        sx={{ bgcolor: 'white', color: '#475569', borderRadius: 2, px: 2, py: 0.8, textTransform: 'none', fontWeight: 600, boxShadow: '0 1px 2px rgba(0,0,0,0.05)', border: '1px solid #E2E8F0' }}
                    >
                        30 jours
                    </Button>
                    <Button
                        endIcon={<KeyboardArrowDownIcon sx={{ fontSize: 18 }} />}
                        sx={{ bgcolor: 'white', color: '#475569', borderRadius: 2, px: 2, py: 0.8, textTransform: 'none', fontWeight: 600, boxShadow: '0 1px 2px rgba(0,0,0,0.05)', border: '1px solid #E2E8F0' }}
                    >
                        Tous les services
                    </Button>
                </Stack>
            </Stack>

            {/* ERROR state */}
            {!summary && (
                <Box sx={{ p: 3, bgcolor: '#FEF2F2', color: '#991B1B', borderRadius: 2, border: '1px solid #FECACA' }}>
                    <Typography fontWeight={700} mb={1}>Erreur de chargement</Typography>
                    <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                        Détails : {error || "Impossible de contacter le serveur (Network Error)"}
                    </Typography>
                    <Typography variant="caption" display="block" mt={1}>
                        Vérifiez que le backend tourne sur le port 8080.
                    </Typography>
                </Box>
            )}

            {/* KPI Cards Row - FULL WIDTH */}
            {summary && (
                <>
                    <Grid container spacing={3} mb={4} sx={{ width: '100%' }}>
                        {/* Cost Chart */}
                        <Grid item xs={12} sm={6} md={3} lg={3} xl={3}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={2}>
                                    <Box>
                                        <Typography variant="body2" color="#64748B" fontWeight={600} mb={0.5}>Coût réel total</Typography>
                                        <Typography variant="h4" fontWeight={800} color="#0F172A" sx={{ letterSpacing: '-1px' }}>
                                            {summary.totalRealCost?.toLocaleString('fr-FR')} €
                                        </Typography>
                                    </Box>
                                    <Box sx={{ bgcolor: '#EFF6FF', p: 1.2, borderRadius: 2, color: '#2563EB', minWidth: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <AttachMoneyIcon fontSize="medium" />
                                    </Box>
                                </Stack>
                                <Stack direction="row" alignItems="center" spacing={0.5}>
                                    {summary.totalRealCostTrend >= 0 ?
                                        <TrendingUpIcon sx={{ fontSize: 18, color: '#EF4444' }} /> :
                                        <TrendingDownIcon sx={{ fontSize: 18, color: '#10B981' }} />
                                    }
                                    <Typography variant="body2" color={summary.totalRealCostTrend >= 0 ? "#EF4444" : "#10B981"} fontWeight={700}>
                                        {summary.totalRealCostTrend > 0 ? '+' : ''}{summary.totalRealCostTrend?.toFixed(1)}%
                                        <Box component="span" sx={{ color: '#94A3B8', fontWeight: 500 }}> vs période précédente</Box>
                                    </Typography>
                                </Stack>
                            </Paper>
                        </Grid>
                        {/* Predicted Chart */}
                        <Grid item xs={12} sm={6} md={3} lg={3} xl={3}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={2}>
                                    <Box>
                                        <Typography variant="body2" color="#64748B" fontWeight={600} mb={0.5}>Coût prédit total</Typography>
                                        <Typography variant="h4" fontWeight={800} color="#0F172A" sx={{ letterSpacing: '-1px' }}>
                                            {summary.totalPredictedCost?.toLocaleString('fr-FR')} €
                                        </Typography>
                                    </Box>
                                    <Box sx={{ bgcolor: '#ECFDF5', p: 1.2, borderRadius: 2, color: '#059669', minWidth: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <TrendingUpIcon fontSize="medium" />
                                    </Box>
                                </Stack>
                                <Stack direction="row" alignItems="center" spacing={0.5}>
                                    {summary.totalPredictedCostTrend >= 0 ?
                                        <TrendingUpIcon sx={{ fontSize: 18, color: '#EF4444' }} /> :
                                        <TrendingDownIcon sx={{ fontSize: 18, color: '#10B981' }} />
                                    }
                                    <Typography variant="body2" color={summary.totalPredictedCostTrend >= 0 ? "#EF4444" : "#10B981"} fontWeight={700}>
                                        {summary.totalPredictedCostTrend > 0 ? '+' : ''}{summary.totalPredictedCostTrend?.toFixed(1)}%
                                        <Box component="span" sx={{ color: '#94A3B8', fontWeight: 500 }}> vs coût réel actuel</Box>
                                    </Typography>
                                </Stack>
                            </Paper>
                        </Grid>
                        {/* Avg Cost Chart */}
                        <Grid item xs={12} sm={6} md={3} lg={3} xl={3}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={2}>
                                    <Box>
                                        <Typography variant="body2" color="#64748B" fontWeight={600} mb={0.5}>Coût moyen par séjour</Typography>
                                        <Typography variant="h4" fontWeight={800} color="#0F172A" sx={{ letterSpacing: '-1px' }}>
                                            {summary.avgCostPerStay?.toLocaleString('fr-FR')} €
                                        </Typography>
                                    </Box>
                                    <Box sx={{ bgcolor: '#F5F3FF', p: 1.2, borderRadius: 2, color: '#7C3AED', minWidth: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <PeopleOutlineIcon fontSize="medium" />
                                    </Box>
                                </Stack>
                                <Stack direction="row" alignItems="center" spacing={0.5}>
                                    {summary.avgCostPerStayTrend >= 0 ?
                                        <TrendingUpIcon sx={{ fontSize: 18, color: '#EF4444' }} /> :
                                        <TrendingDownIcon sx={{ fontSize: 18, color: '#10B981' }} />
                                    }
                                    <Typography variant="body2" color={summary.avgCostPerStayTrend >= 0 ? "#EF4444" : "#10B981"} fontWeight={700}>
                                        {summary.avgCostPerStayTrend > 0 ? '+' : ''}{summary.avgCostPerStayTrend?.toFixed(1)}%
                                        <Box component="span" sx={{ color: '#94A3B8', fontWeight: 500 }}> vs période précédente</Box>
                                    </Typography>
                                </Stack>
                            </Paper>
                        </Grid>
                        {/* Ratio Chart */}
                        <Grid item xs={12} sm={6} md={3} lg={3} xl={3}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={2}>
                                    <Box>
                                        <Typography variant="body2" color="#64748B" fontWeight={600} mb={0.5}>Ratio coût personnel</Typography>
                                        <Typography variant="h4" fontWeight={800} color="#0F172A" sx={{ letterSpacing: '-1px' }}>
                                            {summary.personnelCostRatio?.toFixed(1)}%
                                        </Typography>
                                    </Box>
                                    <Box sx={{ bgcolor: '#FFF7ED', p: 1.2, borderRadius: 2, color: '#EA580C', minWidth: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <PercentIcon fontSize="medium" />
                                    </Box>
                                </Stack>
                                <Stack direction="row" alignItems="center" spacing={0.5}>
                                    {summary.personnelCostRatioTrend >= 0 ?
                                        <TrendingUpIcon sx={{ fontSize: 18, color: '#EF4444' }} /> :
                                        <TrendingDownIcon sx={{ fontSize: 18, color: '#10B981' }} />
                                    }
                                    <Typography variant="body2" color={summary.personnelCostRatioTrend >= 0 ? "#EF4444" : "#10B981"} fontWeight={700}>
                                        {summary.personnelCostRatioTrend > 0 ? '+' : ''}{summary.personnelCostRatioTrend?.toFixed(1)}%
                                        <Box component="span" sx={{ color: '#94A3B8', fontWeight: 500 }}> (pts de diff)</Box>
                                    </Typography>
                                </Stack>
                            </Paper>
                        </Grid>
                    </Grid>

                    {/* Charts Section - Full Width Side by Side */}
                    <Grid container spacing={3} sx={{ mb: 3, width: '100%' }}>
                        {/* Left: Line Chart */}
                        <Grid item xs={12} sm={12} md={6} lg={6} xl={6} sx={{ width: '100%' }}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Box mb={4}>
                                    <Typography variant="h6" fontWeight={800} color="#0F172A">Coût prédit</Typography>
                                    <Typography variant="body2" color="#64748B" fontWeight={500}>Évolution sur 30 jours</Typography>
                                </Box>
                                <ResponsiveContainer width="100%" height={280}>
                                    <LineChart data={forecastData} margin={{ top: 5, right: 30, left: 0, bottom: 5 }}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                                        <XAxis
                                            dataKey="name"
                                            axisLine={false}
                                            tickLine={false}
                                            tick={{ fill: '#64748B', fontSize: 11, fontWeight: 500 }}
                                            dy={10}
                                            tickFormatter={(val) => {
                                                const date = new Date(val);
                                                return `${date.getDate()}/${date.getMonth() + 1}`;
                                            }}
                                            interval="preserveStartEnd"
                                        />
                                        <YAxis
                                            axisLine={false}
                                            tickLine={false}
                                            tick={{ fill: '#64748B', fontSize: 11, fontWeight: 500 }}
                                            tickFormatter={(val) => `${val / 1000}k€`}
                                            domain={[0, 'dataMax + 2000']}
                                        />
                                        <RechartsTooltip
                                            contentStyle={{ borderRadius: 8, border: 'none', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}
                                            formatter={(value) => [value.toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' €', 'Coût prédit']}
                                        />
                                        <Legend
                                            layout="horizontal"
                                            verticalAlign="bottom"
                                            align="center"
                                            wrapperStyle={{ paddingTop: 20 }}
                                            iconType="plainline"
                                        />
                                        <Line
                                            type="monotone"
                                            dataKey="predicted"
                                            name="Coût prédit"
                                            stroke="#10B981"
                                            strokeWidth={2.5}
                                            strokeDasharray="5 5"
                                            dot={{ r: 4, stroke: '#10B981', strokeWidth: 2, fill: 'white' }}
                                            activeDot={{ r: 6 }}
                                        />
                                    </LineChart>
                                </ResponsiveContainer>
                            </Paper>
                        </Grid>

                        {/* Right: Bar Chart */}
                        <Grid item xs={12} sm={12} md={6} lg={6} xl={6} sx={{ width: '100%' }}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Box mb={4}>
                                    <Typography variant="h6" fontWeight={800} color="#0F172A">Coût par service</Typography>
                                    <Typography variant="body2" color="#64748B" fontWeight={500}>Répartition par département</Typography>
                                </Box>
                                {summary?.costByService && summary.costByService.length > 0 ? (
                                    <ResponsiveContainer width="100%" height={280}>
                                        <BarChart data={summary.costByService} margin={{ top: 5, right: 10, left: 0, bottom: 5 }}>
                                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                                            <XAxis
                                                dataKey="name"
                                                axisLine={false}
                                                tickLine={false}
                                                tick={{ fill: '#64748B', fontSize: 11, fontWeight: 500 }}
                                                dy={10}
                                                angle={-20}
                                                textAnchor="end"
                                                interval={0}
                                            />
                                            <YAxis
                                                axisLine={false}
                                                tickLine={false}
                                                tick={{ fill: '#64748B', fontSize: 11, fontWeight: 500 }}
                                                tickFormatter={(val) => `${val / 1000}k€`}
                                                domain={[0, 'dataMax + 5000']}
                                            />
                                            <RechartsTooltip
                                                cursor={{ fill: '#F1F5F9' }}
                                                contentStyle={{ borderRadius: 8, border: 'none' }}
                                            />
                                            <Bar
                                                dataKey="value"
                                                fill="#1E3A8A"
                                                radius={[4, 4, 0, 0]}
                                                barSize={50}
                                            />
                                        </BarChart>
                                    </ResponsiveContainer>
                                ) : (
                                    <Box sx={{ height: 280, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#64748B' }}>
                                        <Typography>Chargement des données...</Typography>
                                    </Box>
                                )}
                            </Paper>
                        </Grid>
                    </Grid>

                    {/* Bottom Row - Full Width Side by Side */}
                    <Grid container spacing={3} sx={{ width: '100%' }}>
                        {/* Donut Chart */}
                        <Grid item xs={12} sm={12} md={6} lg={6} xl={6} sx={{ width: '100%' }}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Box mb={2}>
                                    <Typography variant="h6" fontWeight={800} color="#0F172A">Répartition des coûts</Typography>
                                    <Typography variant="body2" color="#64748B" fontWeight={500}>Par catégorie</Typography>
                                </Box>
                                <ResponsiveContainer width="100%" height={250}>
                                    <PieChart>
                                        <Pie
                                            data={summary.costByCategory}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={85}
                                            paddingAngle={2}
                                            dataKey="value"
                                            stroke="white"
                                            strokeWidth={2}
                                        >
                                            {summary.costByCategory?.map((entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COLORS_PIE[index % COLORS_PIE.length]} />
                                            ))}
                                        </Pie>
                                        <Legend
                                            layout="vertical"
                                            verticalAlign="middle"
                                            align="right"
                                            iconType="circle"
                                            wrapperStyle={{ fontSize: '12px', fontWeight: 500, color: '#64748B', paddingLeft: '20px' }}
                                        />
                                        <RechartsTooltip
                                            contentStyle={{ borderRadius: 8, border: 'none' }}
                                            formatter={(value) => `${value.toLocaleString('fr-FR')} €`}
                                        />
                                    </PieChart>
                                </ResponsiveContainer>
                            </Paper>
                        </Grid>

                        {/* Recent Stays */}
                        <Grid item xs={12} sm={12} md={6} lg={6} xl={6} sx={{ width: '100%' }}>
                            <Paper elevation={0} sx={cardStyle}>
                                <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
                                    <Box>
                                        <Typography variant="h6" fontWeight={800} color="#0F172A">Séjours récents</Typography>
                                        <Typography variant="body2" color="#64748B" fontWeight={500}>Dernières activités</Typography>
                                    </Box>
                                    <Button variant="outlined" size="small" sx={{ borderRadius: 2, textTransform: 'none', borderColor: '#E2E8F0', color: '#0F172A', fontWeight: 600 }}>
                                        Voir tout
                                    </Button>
                                </Stack>
                                <List dense disablePadding>
                                    {summary.recentStays?.map((stay, index) => (
                                        <React.Fragment key={index}>
                                            <ListItem
                                                sx={{
                                                    px: 1,
                                                    py: 2,
                                                    borderBottom: index < summary.recentStays.length - 1 ? '1px solid #F1F5F9' : 'none'
                                                }}
                                            >
                                                <Box sx={{ p: 1.2, bgcolor: '#F8FAFC', borderRadius: 2, mr: 2, border: '1px solid #E2E8F0' }}>
                                                    <EventIcon sx={{ color: '#64748B', fontSize: 20 }} />
                                                </Box>
                                                <ListItemText
                                                    primary={<Typography fontWeight={600} color="#0F172A" fontSize={14}>{stay.patientName}</Typography>}
                                                    secondary={<Typography variant="caption" color="#64748B" fontWeight={500}>{stay.department}</Typography>}
                                                />
                                                <Stack direction="row" alignItems="center" spacing={3}>
                                                    <Chip
                                                        label={stay.status}
                                                        size="small"
                                                        sx={{
                                                            height: 24,
                                                            bgcolor: stay.status === 'En cours' ? '#1E293B' : 'white',
                                                            color: stay.status === 'En cours' ? 'white' : '#64748B',
                                                            border: stay.status !== 'En cours' ? '1px solid #E2E8F0' : 'none',
                                                            fontWeight: 600,
                                                            borderRadius: 4,
                                                            fontSize: 11
                                                        }}
                                                    />
                                                    <Typography fontWeight={700} color="#0F172A" sx={{ minWidth: 80, textAlign: 'right', fontSize: 14 }}>
                                                        {stay.cost.toLocaleString('fr-FR')} €
                                                    </Typography>
                                                </Stack>
                                            </ListItem>
                                        </React.Fragment>
                                    ))}
                                </List>
                            </Paper>
                        </Grid>
                    </Grid>
                </>
            )}

            {summary?.smartAlert && (
                <Paper
                    elevation={0}
                    sx={{
                        mt: 4,
                        p: 2.5,
                        bgcolor: '#FFF7ED',
                        borderRadius: 3,
                        display: 'flex',
                        alignItems: 'center',
                        gap: 2,
                        border: '1px solid #FED7AA'
                    }}
                >
                    <Box sx={{ bgcolor: '#F97316', p: 1.2, borderRadius: 2, color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 40, height: 40 }}>
                        <TrendingUpIcon fontSize="small" />
                    </Box>
                    <Box sx={{ flex: 1 }}>
                        <Typography variant="body2" color="#C2410C" sx={{ lineHeight: 1.6 }}>
                            {summary.smartAlert?.message}
                        </Typography>
                    </Box>
                    <Button
                        variant="contained"
                        size="small"
                        sx={{
                            ml: 2,
                            bgcolor: '#1E293B',
                            textTransform: 'none',
                            fontWeight: 600,
                            borderRadius: 2,
                            px: 2.5,
                            py: 1,
                            boxShadow: 'none',
                            '&:hover': { bgcolor: '#0F172A' }
                        }}
                    >
                        Analyser en détail
                    </Button>
                </Paper>
            )}

        </Box>
    );
};

export default Dashboard;
