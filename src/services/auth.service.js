import logger from "#config/logger.js";
import bcryptjs from "bcrypt";
import {users} from "#models/user.model.js";
import { db } from '#config/database.js';
import { eq } from 'drizzle-orm';

export const hashPassword= async (password)=>{
    try {
        return await bcryptjs.hashSync(password, 12);

    }catch (e) {
        logger.error(e);
        throw new Error('Wrong Hash');
    }
}

export const comparePassword = async (password, hashedPassword) => {
    try {
        return await bcryptjs.compare(password, hashedPassword);
    } catch (e) {
        logger.error('Password comparison failed:', e);
        throw new Error('Password comparison failed');
    }
};

export const authenticateUser = async ({ email, password }) => {
    try {
        const existingUser = await db
            .select()
            .from(users)
            .where(eq(users.email, email))
            .limit(1);

        if (existingUser.length === 0) {
            throw new Error('User not found');
        }

        const user = existingUser[0];
        const isPasswordValid = await comparePassword(password, user.password);

        if (!isPasswordValid) {
            throw new Error('Invalid password');
        }

        logger.info(`User ${user.email} authenticated successfully`);
        return {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: user.created_at,
        };
    } catch (e) {
        logger.error(`Authentication error: ${e.message}`);
        throw e;
    }
};

export const createUser = async ({ name, email, password, role = 'user' }) => {
    try {
        const existingUser = await db
            .select()
            .from(users)
            .where(eq(users.email, email))
            .limit(1);

        if (existingUser.length > 0)
            throw new Error('User with this email already exists');

        const password_hash = await hashPassword(password);

        const [newUser] = await db
            .insert(users)
            .values({ name, email, password: password_hash, role })
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                created_at: users.created_at,
            });

        logger.info(`User ${newUser.email} created successfully`);
        return newUser;
    } catch (e) {
        logger.error(`Error creating the user: ${e}`);
        throw e;
    }
};

