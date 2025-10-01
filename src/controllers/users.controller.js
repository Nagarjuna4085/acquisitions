import logger from "#config/logger.js";
import { getAllUsers as getAllUsersService, getUserById as getUserByIdService, updateUser as updateUserService, deleteUser as deleteUserService } from "#services/users.services.js";
import { userIdSchema, updateUserSchema } from "#validations/users.validation.js";
import { formatValidationError } from "#utils/format.js";
import { hashPassword } from "#services/auth.service.js";

export const getAllUsers = async (req, res, next) => {
    try {
        logger.info('Getting all users');
        const users = await getAllUsersService();
        return res.status(200).json({
            success: true,
            message: 'All users retrieved successfully',
            users: users,
            count: users.length,
        });
    } catch (e) {
        logger.error('Error in getAllUsers controller:', e);
        next(e);
    }
};

export const getUserById = async (req, res, next) => {
    try {
        // Validate the ID parameter
        const paramValidation = userIdSchema.safeParse({ id: req.params.id });
        
        if (!paramValidation.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(paramValidation.error)
            });
        }

        const { id } = paramValidation.data;
        
        logger.info(`Getting user with ID: ${id}`);
        const user = await getUserByIdService(id);
        
        return res.status(200).json({
            success: true,
            message: 'User retrieved successfully',
            user: user
        });
    } catch (e) {
        logger.error('Error in getUserById controller:', e);
        
        if (e.message === 'User not found') {
            return res.status(404).json({
                error: 'User not found',
                message: 'User with the specified ID does not exist'
            });
        }
        
        next(e);
    }
};

export const updateUser = async (req, res, next) => {
    try {
        // Validate the ID parameter
        const paramValidation = userIdSchema.safeParse({ id: req.params.id });
        
        if (!paramValidation.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(paramValidation.error)
            });
        }

        // Validate the update data
        const bodyValidation = updateUserSchema.safeParse(req.body);
        
        if (!bodyValidation.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(bodyValidation.error)
            });
        }

        const { id } = paramValidation.data;
        const updates = bodyValidation.data;
        
        // Authorization: Users can only update their own information
        // unless they are admin
        if (req.user.role !== 'admin' && req.user.id !== id) {
            return res.status(403).json({
                error: 'Access denied',
                message: 'You can only update your own profile'
            });
        }
        
        // Only admin users can change roles
        if (updates.role && req.user.role !== 'admin') {
            return res.status(403).json({
                error: 'Access denied',
                message: 'Only admin users can change user roles'
            });
        }
        
        logger.info(`Updating user with ID: ${id}`, { updateFields: Object.keys(updates) });
        const updatedUser = await updateUserService(id, updates);
        
        return res.status(200).json({
            success: true,
            message: 'User updated successfully',
            user: updatedUser
        });
    } catch (e) {
        logger.error('Error in updateUser controller:', e);
        
        if (e.message === 'User not found') {
            return res.status(404).json({
                error: 'User not found',
                message: 'User with the specified ID does not exist'
            });
        }
        
        next(e);
    }
};

export const deleteUser = async (req, res, next) => {
    try {
        // Validate the ID parameter
        const paramValidation = userIdSchema.safeParse({ id: req.params.id });
        
        if (!paramValidation.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(paramValidation.error)
            });
        }

        const { id } = paramValidation.data;
        
        // Authorization: Users can only delete their own account
        // unless they are admin
        if (req.user.role !== 'admin' && req.user.id !== id) {
            return res.status(403).json({
                error: 'Access denied',
                message: 'You can only delete your own account'
            });
        }
        
        // Prevent admin from deleting themselves (optional safety measure)
        if (req.user.role === 'admin' && req.user.id === id) {
            return res.status(403).json({
                error: 'Action not allowed',
                message: 'Admin users cannot delete their own account'
            });
        }
        
        logger.info(`Deleting user with ID: ${id}`);
        const deletedUser = await deleteUserService(id);
        
        return res.status(200).json({
            success: true,
            message: 'User deleted successfully',
            user: deletedUser
        });
    } catch (e) {
        logger.error('Error in deleteUser controller:', e);
        
        if (e.message === 'User not found') {
            return res.status(404).json({
                error: 'User not found',
                message: 'User with the specified ID does not exist'
            });
        }
        
        next(e);
    }
};
