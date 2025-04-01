import app from "./app";
import supertokens from "./config/appwrite";
import sequelize from "./config/db";

const port = process.env.PORT || 3000;

app.listen(port, () => {
    console.log(`✅ AllenAPI is running on http://localhost:${port}`);
})