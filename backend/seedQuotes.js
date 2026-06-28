require('dotenv').config();
const mongoose = require('mongoose');
const QuotePool = require('./src/models/QuotePool');

const seedQuotes = [
  {
    quoteText: "You have power over your mind - not outside events. Realize this, and you will find strength.",
    author: "Marcus Aurelius",
    topic: "Stoicism",
    explanation: "A core principle of Stoicism: focus only on what you can control. External events are indifferent; your reaction is everything."
  },
  {
    quoteText: "Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.",
    author: "Antoine de Saint-Exupéry",
    topic: "Minimalism",
    explanation: "True elegance and functionality come from reduction. Strip away the non-essential to reveal what truly matters."
  },
  {
    quoteText: "Amateurs sit and wait for inspiration, the rest of us just get up and go to work.",
    author: "Stephen King",
    topic: "Productivity",
    explanation: "Action precedes motivation, not the other way around. Discipline is reliable; inspiration is fleeting."
  },
  {
    quoteText: "He who has a why to live for can bear almost any how.",
    author: "Friedrich Nietzsche",
    topic: "Resilience",
    explanation: "Purpose is the ultimate armor against hardship. When your reason is strong enough, the suffering becomes manageable."
  },
  {
    quoteText: "Simplicity is the ultimate sophistication.",
    author: "Leonardo da Vinci",
    topic: "Design",
    explanation: "Complexity is easy. Distilling something down to its purest, simplest form requires true mastery."
  },
  {
    quoteText: "We suffer more often in imagination than in reality.",
    author: "Seneca",
    topic: "Mental Health",
    explanation: "Anxiety is the act of pre-living a catastrophe that hasn't happened. Ground yourself in the present reality."
  },
  {
    quoteText: "The impediment to action advances action. What stands in the way becomes the way.",
    author: "Marcus Aurelius",
    topic: "Stoicism",
    explanation: "Obstacles are not blockers; they are instructions. Every problem is an opportunity to practice virtue and resilience."
  },
  {
    quoteText: "Focus on being productive instead of busy.",
    author: "Tim Ferriss",
    topic: "Focus",
    explanation: "Activity does not equal achievement. Ruthlessly prioritize what actually moves the needle."
  },
  {
    quoteText: "To find yourself, think for yourself.",
    author: "Socrates",
    topic: "Wisdom",
    explanation: "True wisdom comes from challenging accepted dogma and developing your own internal compass."
  },
  {
    quoteText: "The secret of getting ahead is getting started.",
    author: "Mark Twain",
    topic: "Motivation",
    explanation: "The hardest part of any endeavor is overcoming inertia. Take the smallest possible first step."
  }
];

async function runSeed() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected.');

    console.log('Clearing existing QuotePool (optional)...');
    // await QuotePool.deleteMany({}); // Uncomment if you want to wipe it first

    let inserted = 0;
    for (const data of seedQuotes) {
      const exists = await QuotePool.findOne({ quoteText: data.quoteText });
      if (!exists) {
        await QuotePool.create({
          quoteText: data.quoteText,
          author: data.author,
          topic: data.topic,
          explanation: data.explanation,
          usedBy: [],
        });
        inserted++;
      }
    }
    
    console.log(`Successfully seeded ${inserted} new quotes into the QuotePool!`);
    process.exit(0);
  } catch (err) {
    console.error('Error seeding data:', err);
    process.exit(1);
  }
}

runSeed();
