import React from 'react';
import {
    Dialog,
    DialogTitle,
    DialogContent,
    DialogContentText,
    DialogActions,
    Button,
    Box,
    Typography,
    alpha
} from '@mui/material';
import WarningAmberRoundedIcon from '@mui/icons-material/WarningAmberRounded';

const DeleteConfirmationDialog = ({ open, onClose, onConfirm, itemName }) => {
    return (
        <Dialog
            open={open}
            onClose={onClose}
            PaperProps={{
                sx: {
                    borderRadius: 3,
                    boxShadow: '0px 10px 40px rgba(0,0,0,0.1)',
                    overflow: 'visible',
                    mt: 2
                }
            }}
            maxWidth="xs"
            fullWidth
        >
            <Box
                sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    mb: -3,
                    zIndex: 1,
                    position: 'relative',
                }}
            >
                <Box
                    sx={{
                        bgcolor: '#FEF2F2',
                        color: 'error.main',
                        width: 64,
                        height: 64,
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        border: '4px solid white',
                        boxShadow: '0px 4px 12px rgba(239, 68, 68, 0.15)'
                    }}
                >
                    <WarningAmberRoundedIcon sx={{ fontSize: 32 }} />
                </Box>
            </Box>

            <DialogTitle sx={{ textAlign: 'center', pt: 4, pb: 1 }}>
                <Typography variant="h6" fontWeight="bold">
                    Confirmer la suppression
                </Typography>
            </DialogTitle>

            <DialogContent>
                <DialogContentText sx={{ textAlign: 'center', color: 'text.secondary' }}>
                    Êtes-vous sûr de vouloir supprimer {itemName ? <strong>{itemName}</strong> : "cet élément"} ?
                    <br />
                    Cette action est irréversible.
                </DialogContentText>
            </DialogContent>

            <DialogActions sx={{ p: 3, pt: 0, justifyContent: 'center', gap: 2 }}>
                <Button
                    onClick={onClose}
                    variant="outlined"
                    sx={{
                        borderRadius: 2,
                        textTransform: 'none',
                        color: 'text.secondary',
                        borderColor: '#E2E8F0',
                        px: 3,
                        '&:hover': { borderColor: '#CBD5E1', bgcolor: '#F8FAFC' }
                    }}
                >
                    Annuler
                </Button>
                <Button
                    onClick={onConfirm}
                    variant="contained"
                    color="error"
                    autoFocus
                    sx={{
                        borderRadius: 2,
                        textTransform: 'none',
                        boxShadow: '0px 4px 12px rgba(239, 68, 68, 0.2)',
                        px: 3,
                        bgcolor: '#DC2626',
                        '&:hover': { bgcolor: '#B91C1C' }
                    }}
                >
                    Supprimer
                </Button>
            </DialogActions>
        </Dialog>
    );
};

export default DeleteConfirmationDialog;
