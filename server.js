const CharacterAI = require('node_characterai');
const characterAI = new CharacterAI();
const botConfig = require("./botConfig.json");
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

function isFiltered(message) {
    if (!message) return true;
    return message.includes("#") || message.trim() === "";
}

app.use(cors({
    origin: '*',
    methods: ['POST', 'GET'],
    allowedHeaders: ['Content-Type', 'Accept']
}));
app.use(express.json());

let aiChat = null;

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

app.post('/chat', async (req, res) => {
    try {
        const { message } = req.body;

        if (isFiltered(message)) {
            return res.json({ 
                filtered: true,
                response: '[Message Filtered]'
            });
        }

        if (!aiChat) {
            const initialized = await initializeAI();
            if (!initialized) {
                return res.json({ 
                    error: true,
                    response: 'AI service unavailable'
                });
            }
        }

        console.log("Message:", message);
        const response = await aiChat.sendAndAwaitResponse(message, true);
        console.log("AI Message:", response.text);
        
        res.json({ 
            filtered: false,
            response: response.text 
        });

    } catch (error) {
        console.error("Message Error:", error);
        res.json({ 
            error: true,
            response: 'Error Request'
        });
    }
});

app.listen(PORT, async () => {
    await initializeAI();
    console.log(`Server running on http://localhost:${PORT}`);
});
