import express from 'express';
import config from './config';

import cardsRoutes from './routes/cards.routes';

const app = express();

//settings
app.set('port', config.port || 3000);

app.use(cardsRoutes);

export default app;