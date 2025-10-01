import express from 'express';
import { getAllUsers, getUserById, updateUser, deleteUser } from "#controllers/users.controller.js";
import { authenticateToken } from "#middleware/auth.middleware.js";

const router = express.Router();

// Protected routes - require authentication
router.get('/', authenticateToken, getAllUsers);
router.get('/:id', authenticateToken, getUserById);
router.put('/:id', authenticateToken, updateUser);
router.delete('/:id', authenticateToken, deleteUser);

export default router;
