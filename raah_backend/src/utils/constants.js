/**
 * Application-wide constants.
 * Centralising magic strings / numbers here prevents typos
 * and makes future changes painless.
 */

const ROLES = Object.freeze({
  CUSTOMER: 'customer',
  BROKER: 'broker',
  OWNER: 'owner',
});

const APPOINTMENT_STATUS = Object.freeze({
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  REJECTED: 'rejected',
});

const WALLET_TX_TYPE = Object.freeze({
  CREDIT: 'credit',
  DEBIT: 'debit',
});

module.exports = {
  ROLES,
  APPOINTMENT_STATUS,
  WALLET_TX_TYPE,
};
