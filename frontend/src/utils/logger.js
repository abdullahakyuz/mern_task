const log = {
  info: (...params) => console.log('[INFO]', ...params),
  error: (...params) => console.error('[ERROR]', ...params),
};

export default log;