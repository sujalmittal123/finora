import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();
router.use(authenticate);

// GET /api/v1/categories
router.get('/', async (_req, res, next) => {
  try {
    const categories = await prisma.category.findMany({ orderBy: { name: 'asc' } });
    res.json(categories);
  } catch (err) { next(err); }
});

export default router;
