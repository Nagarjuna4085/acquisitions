import {db} from "#config/database.js";
import {users} from "#models/user.model.js";
import logger from "#config/logger.js";
import { eq } from 'drizzle-orm';
import { hashPassword } from "#services/auth.service.js";

export const getAllUsers = async () => {
    try {
        const allUsers = await db.select({
            id: users.id,
            email: users.email,
            name: users.name,
            role: users.role,
            created_at: users.created_at,
            updated_at: users.updated_at,
        }).from(users);
        return allUsers;
    } catch (e) {
        logger.error('Error getting users:', e);
        throw new Error('Failed to retrieve users');
    }
};

export const getUserById = async (id) => {
    try {
        const user = await db.select({
            id: users.id,
            email: users.email,
            name: users.name,
            role: users.role,
            created_at: users.created_at,
            updated_at: users.updated_at,
        })
        .from(users)
        .where(eq(users.id, id))
        .limit(1);

        if (user.length === 0) {
            throw new Error('User not found');
        }

        logger.info(`User with ID ${id} retrieved successfully`);
        return user[0];
    } catch (e) {
        logger.error('Error getting user by ID:', e);
        throw e;
    }
};

export const updateUser = async (id, updates) => {
    try {
        // First check if user exists
        const existingUser = await db
            .select({ id: users.id })
            .from(users)
            .where(eq(users.id, id))
            .limit(1);

        if (existingUser.length === 0) {
            throw new Error('User not found');
        }

        // If password is being updated, hash it
        if (updates.password) {
            updates.password = await hashPassword(updates.password);
        }

        // Add updated_at timestamp
        const updateData = {
            ...updates,
            updated_at: new Date()
        };

        const [updatedUser] = await db
            .update(users)
            .set(updateData)
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                created_at: users.created_at,
                updated_at: users.updated_at,
            });

        logger.info(`User with ID ${id} updated successfully`);
        return updatedUser;
    } catch (e) {
        logger.error('Error updating user:', e);
        throw e;
    }
};

export const deleteUser = async (id) => {
    try {
        // First check if user exists
        const existingUser = await db
            .select({ id: users.id, email: users.email })
            .from(users)
            .where(eq(users.id, id))
            .limit(1);

        if (existingUser.length === 0) {
            throw new Error('User not found');
        }

        const [deletedUser] = await db
            .delete(users)
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role
            });

        logger.info(`User with ID ${id} (${existingUser[0].email}) deleted successfully`);
        return deletedUser;
    } catch (e) {
        logger.error('Error deleting user:', e);
        throw e;
    }
};
