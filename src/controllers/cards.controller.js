import {getConnection} from '../database/connection';

export const getCards = async (req, res) => {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT * FROM cards');
    console.log(result);

    res.json("cards");
};
    