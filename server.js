//import 'dotenv/config'; //<-- for dev only
import express from 'express';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { fileURLToPath } from 'url';



const fileName = fileURLToPath(import.meta.url);
const dirName = path.dirname(fileName);

const { GATEWAY } = process.env;
if (!GATEWAY) throw new Error('GATEWAY env var is required');

const app = express();

app.set('trust proxy', true);

// packages
app.use('/pkg/alpine', express.static('node_modules/alpinejs/dist'))


// Parse JSON bodies as sent by API clients
app.use(express.json({strict: true, limit: "100kb", type: "application/json"}));


// limited to 15 requests per minute
const dataLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 15,
  standardHeaders: 'draft-7', // sends RateLimit-* headers
  legacyHeaders: false,
  keyGenerator: (req) => req.ip,
  message: { error: 'Request limit exceeded. ' },
});

// Serve files under / (so '/' serves static/index.html if it exists)
app.use(express.static(path.join(dirName, 'static')));

app.use('/data', dataLimiter);
app.get('/data', async (req, res) => {
    
    try {
        const ip = `${req.ip}`;
        //const ip = "enter ip address here for local testing";
        const resp = await fetch(`${GATEWAY}${ip}`);
        const data = await resp.json();
        res.json(data);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error contacting Gateway');
    }
});

app.listen(3000, () => console.log('Server running on localhost port 3000.'))