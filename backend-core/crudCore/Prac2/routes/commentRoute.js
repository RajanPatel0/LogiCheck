import express from 'express';
import {createComment, getComment} from '../controllers/commentController.js';

const router = express.Router();

router.post("/", createComment);
router.get("/", getComment);

export default router;