require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Property = require('../models/Property');
const Appointment = require('../models/Appointment');
const WalletTransaction = require('../models/WalletTransaction');
const { ROLES, APPOINTMENT_STATUS, WALLET_TX_TYPE } = require('../utils/constants');

/**
 * Seed script to populate database with test data
 * Usage: node src/scripts/seed.js
 */

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    process.exit(1);
  }
};

const seedDatabase = async () => {
  try {
    // Drop all collections and indexes to start fresh
    console.log('🗑️  Clearing existing data and indexes...');
    
    // Drop collections (this also drops all indexes)
    try {
      await User.collection.drop();
    } catch (e) {
      // Collection might not exist
    }
    try {
      await Property.collection.drop();
    } catch (e) {
      // Collection might not exist
    }
    try {
      await Appointment.collection.drop();
    } catch (e) {
      // Collection might not exist
    }
    try {
      await WalletTransaction.collection.drop();
    } catch (e) {
      // Collection might not exist
    }
    
    // Clear any remaining data
    await User.deleteMany({});
    await Property.deleteMany({});
    await Appointment.deleteMany({});
    await WalletTransaction.deleteMany({});
    
    console.log('✅ Cleared existing data\n');

    // ── Create Users ────────────────────────────────────────
    console.log('👥 Creating users...');
    
    // Customers
    const customer1 = await User.create({
      name: 'John Doe',
      email: 'john@example.com',
      phone: '9876543210',
      password: 'password123',
      role: ROLES.CUSTOMER,
    });

    const customer2 = await User.create({
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '9876543211',
      password: 'password123',
      role: ROLES.CUSTOMER,
    });

    const customer3 = await User.create({
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phone: '9876543212',
      password: 'password123',
      role: ROLES.CUSTOMER,
    });

    // Owners
    const owner1 = await User.create({
      name: 'Robert Williams',
      email: 'robert@example.com',
      phone: '9876543213',
      password: 'password123',
      role: ROLES.OWNER,
    });

    const owner2 = await User.create({
      name: 'Sarah Brown',
      email: 'sarah@example.com',
      phone: '9876543214',
      password: 'password123',
      role: ROLES.OWNER,
    });

    const owner3 = await User.create({
      name: 'David Lee',
      email: 'david@example.com',
      phone: '9876543215',
      password: 'password123',
      role: ROLES.OWNER,
    });

    // Brokers
    const broker1 = await User.create({
      name: 'Alex Broker',
      email: 'alex@example.com',
      phone: '9876543216',
      password: 'password123',
      role: ROLES.BROKER,
      wallet: 150,
    });

    const broker2 = await User.create({
      name: 'Emma Realty',
      email: 'emma@example.com',
      phone: '9876543217',
      password: 'password123',
      role: ROLES.BROKER,
      wallet: 80,
    });

    console.log('✅ Created users\n');

    // ── Create Properties ───────────────────────────────────
    console.log('🏠 Creating properties...');

    const properties = [
      {
        title: 'Spacious 2BHK Apartment in Downtown',
        description: 'Beautiful 2 bedroom apartment with modern amenities. Located in the heart of the city with easy access to shopping malls, schools, and hospitals. Fully furnished with AC, modular kitchen, and parking space.',
        rent: 25000,
        deposit: 50000,
        area: 'Downtown',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
        ],
        amenities: ['AC', 'Parking', 'Lift', 'Security', 'Power Backup'],
        ownerId: owner1._id,
        brokerId: broker1._id,
      },
      {
        title: 'Luxury 3BHK Villa with Garden',
        description: 'Stunning 3 bedroom villa with private garden and terrace. Perfect for families looking for a peaceful living space. Includes servant quarters, covered parking for 2 cars, and 24/7 security.',
        rent: 60000,
        deposit: 120000,
        area: 'Bandra West',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        ],
        amenities: ['Garden', 'Parking', 'Security', 'Servant Quarters', 'Terrace'],
        ownerId: owner1._id,
        brokerId: broker1._id,
      },
      {
        title: 'Modern 1BHK Studio Apartment',
        description: 'Compact and well-designed 1BHK studio apartment ideal for working professionals. Fully furnished with all modern amenities. Close to metro station and IT parks.',
        rent: 18000,
        deposit: 36000,
        area: 'Andheri East',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        ],
        amenities: ['AC', 'Furnished', 'Lift', 'Security', 'Near Metro'],
        ownerId: owner2._id,
        brokerId: broker1._id,
      },
      {
        title: 'Cozy 2BHK Flat in Residential Area',
        description: 'Well-maintained 2BHK flat in a peaceful residential locality. Great for small families. Includes all basic amenities and is close to schools and markets.',
        rent: 22000,
        deposit: 44000,
        area: 'Powai',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
        ],
        amenities: ['Parking', 'Lift', 'Security', 'Water Supply'],
        ownerId: owner2._id,
        brokerId: null, // Listed by owner directly
      },
      {
        title: 'Premium 4BHK Penthouse',
        description: 'Exclusive 4 bedroom penthouse with panoramic city views. Ultra-luxury living with premium finishes, private elevator, and rooftop terrace. Perfect for high-end living.',
        rent: 150000,
        deposit: 300000,
        area: 'Worli',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
          'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
        ],
        amenities: ['AC', 'Parking', 'Lift', 'Security', 'Gym', 'Swimming Pool', 'Rooftop'],
        ownerId: owner3._id,
        brokerId: broker2._id,
      },
      {
        title: 'Affordable 1BHK in Suburbs',
        description: 'Budget-friendly 1BHK apartment in suburban area. Clean and well-maintained. Suitable for students or young professionals. Close to public transport.',
        rent: 12000,
        deposit: 24000,
        area: 'Thane',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        ],
        amenities: ['Water Supply', 'Security'],
        ownerId: owner3._id,
        brokerId: broker2._id,
      },
      {
        title: 'Family-Friendly 3BHK Apartment',
        description: 'Spacious 3BHK apartment perfect for families. Located in a gated community with children\'s play area, clubhouse, and landscaped gardens. Great connectivity.',
        rent: 45000,
        deposit: 90000,
        area: 'Goregaon',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800',
        ],
        amenities: ['Parking', 'Lift', 'Security', 'Play Area', 'Clubhouse', 'Garden'],
        ownerId: owner1._id,
        brokerId: broker2._id,
      },
      {
        title: 'Compact 1BHK Near Beach',
        description: 'Charming 1BHK apartment just 5 minutes walk from the beach. Great for those who love the sea breeze. Includes basic amenities and is pet-friendly.',
        rent: 20000,
        deposit: 40000,
        area: 'Juhu',
        city: 'Mumbai',
        images: [
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800',
        ],
        amenities: ['Parking', 'Security', 'Near Beach', 'Pet Friendly'],
        ownerId: owner2._id,
        brokerId: null,
      },
    ];

    const createdProperties = await Property.insertMany(properties);
    console.log('✅ Created properties\n');

    // ── Create Appointments ─────────────────────────────────
    console.log('📅 Creating appointments...');

    const appointments = [
      {
        propertyId: createdProperties[0]._id,
        customerId: customer1._id,
        ownerId: owner1._id,
        date: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 days from now
        time: '10:00 AM',
        status: APPOINTMENT_STATUS.PENDING,
      },
      {
        propertyId: createdProperties[0]._id,
        customerId: customer2._id,
        ownerId: owner1._id,
        date: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 3 days from now
        time: '2:00 PM',
        status: APPOINTMENT_STATUS.ACCEPTED,
      },
      {
        propertyId: createdProperties[1]._id,
        customerId: customer1._id,
        ownerId: owner1._id,
        date: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
        time: '11:00 AM',
        status: APPOINTMENT_STATUS.PENDING,
      },
      {
        propertyId: createdProperties[2]._id,
        customerId: customer3._id,
        ownerId: owner2._id,
        date: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // Yesterday
        time: '3:00 PM',
        status: APPOINTMENT_STATUS.ACCEPTED,
      },
      {
        propertyId: createdProperties[3]._id,
        customerId: customer2._id,
        ownerId: owner2._id,
        date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
        time: '4:00 PM',
        status: APPOINTMENT_STATUS.PENDING,
      },
      {
        propertyId: createdProperties[4]._id,
        customerId: customer1._id,
        ownerId: owner3._id,
        date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
        time: '5:00 PM',
        status: APPOINTMENT_STATUS.REJECTED,
      },
      {
        propertyId: createdProperties[5]._id,
        customerId: customer3._id,
        ownerId: owner3._id,
        date: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000), // 4 days from now
        time: '10:30 AM',
        status: APPOINTMENT_STATUS.ACCEPTED,
      },
      {
        propertyId: createdProperties[6]._id,
        customerId: customer2._id,
        ownerId: owner1._id,
        date: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000), // 6 days from now
        time: '1:00 PM',
        status: APPOINTMENT_STATUS.PENDING,
      },
    ];

    await Appointment.insertMany(appointments);
    console.log('✅ Created appointments\n');

    // ── Create Wallet Transactions ──────────────────────────
    console.log('💰 Creating wallet transactions...');

    const walletTransactions = [
      {
        brokerId: broker1._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Spacious 2BHK Apartment',
      },
      {
        brokerId: broker1._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Luxury 3BHK Villa',
      },
      {
        brokerId: broker1._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Modern 1BHK Studio',
      },
      {
        brokerId: broker1._id,
        amount: 50,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Bonus reward for multiple listings',
      },
      {
        brokerId: broker1._id,
        amount: 20,
        type: WALLET_TX_TYPE.DEBIT,
        reason: 'Withdrawal request',
      },
      {
        brokerId: broker2._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Premium 4BHK Penthouse',
      },
      {
        brokerId: broker2._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Affordable 1BHK',
      },
      {
        brokerId: broker2._id,
        amount: 10,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Property listing reward - Family-Friendly 3BHK',
      },
      {
        brokerId: broker2._id,
        amount: 30,
        type: WALLET_TX_TYPE.CREDIT,
        reason: 'Bonus reward for multiple listings',
      },
      {
        brokerId: broker2._id,
        amount: 20,
        type: WALLET_TX_TYPE.DEBIT,
        reason: 'Withdrawal request',
      },
    ];

    await WalletTransaction.insertMany(walletTransactions);
    console.log('✅ Created wallet transactions\n');

    // ── Summary ─────────────────────────────────────────────
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 SEED SUMMARY');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`👥 Users: ${await User.countDocuments()}`);
    console.log(`   - Customers: ${await User.countDocuments({ role: ROLES.CUSTOMER })}`);
    console.log(`   - Owners: ${await User.countDocuments({ role: ROLES.OWNER })}`);
    console.log(`   - Brokers: ${await User.countDocuments({ role: ROLES.BROKER })}`);
    console.log(`🏠 Properties: ${await Property.countDocuments()}`);
    console.log(`📅 Appointments: ${await Appointment.countDocuments()}`);
    console.log(`💰 Wallet Transactions: ${await WalletTransaction.countDocuments()}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('🔑 TEST CREDENTIALS:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Customer:');
    console.log('  Email: john@example.com | Password: password123');
    console.log('  Email: jane@example.com | Password: password123');
    console.log('  Email: mike@example.com | Password: password123');
    console.log('\nOwner:');
    console.log('  Email: robert@example.com | Password: password123');
    console.log('  Email: sarah@example.com | Password: password123');
    console.log('  Email: david@example.com | Password: password123');
    console.log('\nBroker:');
    console.log('  Email: alex@example.com | Password: password123');
    console.log('  Email: emma@example.com | Password: password123');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('✅ Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
};

// Run seed
connectDB().then(() => {
  seedDatabase();
});
