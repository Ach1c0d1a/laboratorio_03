import sql from 'mssql';

export const dbSettings = {
    user: "gerente",
    password: "1234",
    server: "localhost",
    database: "prueba",
    options: {
      encrypt: true, // for azure
      trustServerCertificate: true // change to true for local dev / self-signed certs
    }
  };
  
export async function getConnection() {
  try{
    const pool = await sql.connect(dbSettings);
    const result = await pool.request().query('SELECT 1');
    return result;
  } catch (error) {
    console.error(error);
  }
}

export default getConnection();
