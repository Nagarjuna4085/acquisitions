import 'dotenv/config';

export default {
    schema: './src/models/*.js',
    out: './drizzle',          // ✅ output folder for migrations
    dialect: 'postgresql',
    dbCredentials: {
        url: process.env.DATABASE_URL, // ✅ keep env variable for safety
    },
};
