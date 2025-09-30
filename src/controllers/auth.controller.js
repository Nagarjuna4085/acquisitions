import logger from "#config/logger.js";
import {signupSchema, signInSchema} from "#validations/auth.validation.js";
import {formatValidationError} from "#utils/format.js";
import {createUser, authenticateUser} from "#services/auth.service.js";
import {jwttoken} from "#utils/jwt.js";
import {cookies} from "#utils/cookies.js";

 export const signup = async (req,res,next)=>{
    console.log(req.body);
    debugger
    try {
        const validationResult = signupSchema.safeParse(req.body)

        logger.info(".....bodyyyy",req.body)
        if(!validationResult.success){
            return res.status(400).json({error:'Validation failedhgfdsfgh',details:formatValidationError(validationResult.error),data:req.body});
        }

        const { name, email, password, role } = validationResult.data;

        const user = await createUser( {name, email, password, role});
        const token = jwttoken.sign({id:user.id,email:user.email,role:user.role});
        cookies.set(res,'token',token);

        //AUTH SERVICE
        logger.info(`USER REGISTERED SUCCESSFULLY : ${email}`)

        res.status(201).json({
            success:true,
            message:"User registered successfully",
            user:{
                id:user.id,name:user.name,email:user.email, role:user.role
            }
        })




    }catch(err){
        logger.error('Signup error',err)
        if(err.message === 'User with this email already exists'){
            return res.status(409).json({error:'User with this email already exists'})
        }
        next(err)
    }
}

export const signin = async (req, res, next) => {
    try {
        const validationResult = signInSchema.safeParse(req.body);

        logger.info('Sign-in attempt', { email: req.body.email });
        
        if (!validationResult.success) {
            return res.status(400).json({
                error: 'Validation failed',
                details: formatValidationError(validationResult.error),
                data: req.body
            });
        }

        const { email, password } = validationResult.data;

        const user = await authenticateUser({ email, password });
        const token = jwttoken.sign({ id: user.id, email: user.email, role: user.role });
        cookies.set(res, 'token', token);

        logger.info(`USER SIGNED IN SUCCESSFULLY: ${email}`);

        res.status(200).json({
            success: true,
            message: "User signed in successfully",
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        });
    } catch (err) {
        logger.error('Sign-in error', err);
        
        if (err.message === 'User not found') {
            return res.status(404).json({ error: 'User not found' });
        }
        
        if (err.message === 'Invalid password') {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        next(err);
    }
};

export const signout = async (req, res, next) => {
    try {
        cookies.clear(res, 'token');
        
        logger.info('USER SIGNED OUT SUCCESSFULLY');
        
        res.status(200).json({
            success: true,
            message: "User signed out successfully"
        });
    } catch (err) {
        logger.error('Sign-out error', err);
        next(err);
    }
};
