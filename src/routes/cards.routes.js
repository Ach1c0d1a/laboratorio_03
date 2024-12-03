import {Router} from 'express';

import { getCards } from "../controllers/cards.controller.js";

const router = Router(); 

router.get('/cards', getCards);

router.get('/cards');

export default router; 