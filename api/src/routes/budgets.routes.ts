import { Router, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { authenticate, AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

const router = Router();
router.use(authenticate);

const budgetSchema = z.object({
  name: z.string().min(1),
  limit: z.number().positive(),
  categoryId: z.string(),
  period: z.enum(['WEEKLY', 'MONTHLY', 'YEARLY']).optional(),
  startDate: z.string(),
  endDate: z.string(),
});

// GET /api/v1/budgets
router.get('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const budgets = await prisma.budget.findMany({
      where: { userId: req.userId! },
      include: { category: true },
      orderBy: { createdAt: 'desc' },
    });
    res.json(budgets);
  } catch (err) { next(err); }
});

// POST /api/v1/budgets
router.post('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const data = budgetSchema.parse(req.body);
    const budget = await prisma.budget.create({
      data: {
        ...data,
        startDate: new Date(data.startDate),
        endDate: new Date(data.endDate),
        userId: req.userId!,
      },
      include: { category: true },
    });
    res.status(201).json(budget);
  } catch (err) { next(err); }
});

// PATCH /api/v1/budgets/:id
router.patch('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const data = budgetSchema.partial().parse(req.body);
    const budget = await prisma.budget.findFirst({
      where: { id: req.params.id, userId: req.userId! },
    });
    if (!budget) throw new AppError(404, 'Budget not found');
    const updated = await prisma.budget.update({
      where: { id: req.params.id },
      data: {
        ...data,
        ...(data.startDate ? { startDate: new Date(data.startDate) } : {}),
        ...(data.endDate ? { endDate: new Date(data.endDate) } : {}),
      },
      include: { category: true },
    });
    res.json(updated);
  } catch (err) { next(err); }
});

// DELETE /api/v1/budgets/:id
router.delete('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const budget = await prisma.budget.findFirst({
      where: { id: req.params.id, userId: req.userId! },
    });
    if (!budget) throw new AppError(404, 'Budget not found');
    await prisma.budget.delete({ where: { id: req.params.id } });
    res.status(204).send();
  } catch (err) { next(err); }
});

export default router;
