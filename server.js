const CharacterAI = require('node_characterai');
const characterAI = new CharacterAI();
const botConfig = require("./botConfig.json");
const express = require('express');
const cors = require('cors');
const figlet = require('figlet');

const app = express();
const PORT = 3000;

app.use(cors({
    origin: '*',
    methods: ['POST', 'GET'],
    allowedHeaders: ['Content-Type', 'Accept']
}));
app.use(express.json());

let aiChat = null;

console.log(figlet.textSync('Character.Ai', {
    font: 'Standard',
    horizontalLayout: 'default',
    verticalLayout: 'default'
}));

async function initializeAI() {
    try {
        if (!characterAI.isAuthenticated()) {
            await characterAI.authenticateWithToken(botConfig.authToken);
        }
        aiChat = await characterAI.createOrContinueChat(botConfig.characterID);
        console.log("Character.ai initialized!");
        return true;
    } catch (error) {
        console.error("AI initialization error:", error);
        return false;
    }
}

app.get('/', (req, res) => {
    res.json({ status: 'Server is running' });
});

app.post('/chat', async (req, res) => {
    try {
        const { message } = req.body;

        if (!aiChat) {
            const initialized = await initializeAI();
            if (!initialized) {
                return res.json({ 
                    error: true,
                    response: 'AI service unavailable'
                });
            }
        }

        console.log("Incoming message:", message);
        const response = await aiChat.sendAndAwaitResponse(message, true);
        console.log("AI response:", response.text);
        
        res.json({ 
            filtered: false,
            response: response.text 
        });

    } catch (error) {
        console.error("Message processing error:", error);
        res.json({ 
            error: true,
            response: 'Error processing request'
        });
    }
});

app.listen(PORT, async () => {
    await initializeAI();
    console.log(`Server running on http://localhost:${PORT}`);
});
