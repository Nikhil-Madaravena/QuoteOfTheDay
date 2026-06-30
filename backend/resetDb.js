require('dotenv').config();
const mongoose = require('mongoose');

async function resetDb() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected.');

    const collections = await mongoose.connection.db.collections();
    for (let collection of collections) {
      console.log(`Clearing collection: ${collection.collectionName}...`);
      await collection.deleteMany({});
    }

    console.log('Database wiped completely clean! Starting fresh.');
    process.exit(0);
  } catch (err) {
    console.error('Error resetting database:', err);
    process.exit(1);
  }
}

resetDb();
