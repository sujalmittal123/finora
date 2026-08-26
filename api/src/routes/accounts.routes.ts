import { Router, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { authenticate, AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

const router = Router();
router.use(authenticate);

const accountSchema = z.object({
  name: z.string().min(1),
  type: z.enum(['CHECKING', 'SAVINGS', 'CREDIT', 'INVESTMENT', 'CASH']).optional(),
  balance: z.number().optional(),
  currency: z.string().optional(),
  color: z.string().optional(),
  icon: z.string().optional(),
});

// GET /api/v1/accounts
router.get('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const accounts = await prisma.account.findMany({
      where: { userId: req.userId! },
      orderBy: { createdAt: 'desc' },
    });
    res.json(accounts);
  } catch (err) { next(err); }
});

// POST /api/v1/accounts
router.post('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const data = accountSchema.parse(req.body);
    const account = await prisma.account.create({
      data: { ...data, userId: req.userId! },
    });
    res.status(201).json(account);
  } catch (err) { next(err); }
});

// GET /api/v1/accounts/:id
router.get('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const account = await prisma.account.findFirst({
      where: { id: req.params.id, userId: req.userId! },
      include: { transactions: { orderBy: { date: 'desc' }, take: 20 } },
    });
    if (!account) throw new AppError(404, 'Account not found');
    res.json(account);
  } catch (err) { next(err); }
});

// PATCH /api/v1/accounts/:id
router.patch('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const data = accountSchema.partial().parse(req.body);
    const account = await prisma.account.findFirst({
      where: { id: req.params.id, userId: req.userId! },
    });
    if (!account) throw new AppError(404, 'Account not found');
    const updated = await prisma.account.update({
      where: { id: req.params.id },
      data,
    });
    res.json(updated);
  } catch (err) { next(err); }
});

// DELETE /api/v1/accounts/:id
router.delete('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const account = await prisma.account.findFirst({
      where: { id: req.params.id, userId: req.userId! },
    });
    if (!account) throw new AppError(404, 'Account not found');
    await prisma.account.delete({ where: { id: req.params.id } });
    res.status(204).send();
  } catch (err) { next(err); }
});

export default router;
