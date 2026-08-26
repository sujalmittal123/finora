import { Router, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { authenticate, AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

const router = Router();
router.use(authenticate);

const txSchema = z.object({
  amount: z.number().positive(),
  type: z.enum(['INCOME', 'EXPENSE']),
  accountId: z.string(),
  categoryId: z.string(),
  note: z.string().optional(),
  date: z.string().optional(),
});

// GET /api/v1/transactions?accountId=&type=&from=&to=&page=&limit=
router.get('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const { accountId, type, from, to, page = '1', limit = '20' } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    const transactions = await prisma.transaction.findMany({
      where: {
        account: { userId: req.userId! },
        ...(accountId ? { accountId: String(accountId) } : {}),
        ...(type ? { type: type as 'INCOME' | 'EXPENSE' } : {}),
        ...(from || to
          ? {
              date: {
                ...(from ? { gte: new Date(String(from)) } : {}),
                ...(to ? { lte: new Date(String(to)) } : {}),
              },
            }
          : {}),
      },
      include: { category: true, account: { select: { name: true, currency: true } } },
      orderBy: { date: 'desc' },
      skip,
      take: Number(limit),
    });

    res.json(transactions);
  } catch (err) { next(err); }
});

// POST /api/v1/transactions
router.post('/', async (req: AuthRequest, res: Response, next) => {
  try {
    const data = txSchema.parse(req.body);

    // Verify account belongs to user
    const account = await prisma.account.findFirst({
      where: { id: data.accountId, userId: req.userId! },
    });
    if (!account) throw new AppError(404, 'Account not found');

    const tx = await prisma.$transaction(async (db) => {
      const transaction = await db.transaction.create({
        data: {
          ...data,
          date: data.date ? new Date(data.date) : new Date(),
        },
        include: { category: true },
      });

      // Update account balance
      const delta = data.type === 'INCOME' ? data.amount : -data.amount;
      await db.account.update({
        where: { id: data.accountId },
        data: { balance: { increment: delta } },
      });

      return transaction;
    });

    res.status(201).json(tx);
  } catch (err) { next(err); }
});

// DELETE /api/v1/transactions/:id
router.delete('/:id', async (req: AuthRequest, res: Response, next) => {
  try {
    const tx = await prisma.transaction.findFirst({
      where: { id: req.params.id, account: { userId: req.userId! } },
    });
    if (!tx) throw new AppError(404, 'Transaction not found');

    await prisma.$transaction(async (db) => {
      await db.transaction.delete({ where: { id: req.params.id } });
      const delta = tx.type === 'INCOME' ? -tx.amount : tx.amount;
      await db.account.update({
        where: { id: tx.accountId },
        data: { balance: { increment: delta } },
      });
    });

    res.status(204).send();
  } catch (err) { next(err); }
});

export default router;
