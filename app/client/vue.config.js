module.exports = {
  devServer: {
    port: 5000,
    overlay: {
      warnings: true,
      errors: true
    },
    proxy: {
      "/api": {
        target: process.env.API_BASEURL, //ADD THIS TO .ENV VARIABLES
        changeOrigin: true
      },
      "/geoserver": {
        target: process.env.GEOSERVER_BASEURL, //ADD THIS TO .ENV VARIABLES
        changeOrigin: true
      }
    }
  },

  pluginOptions: {
    i18n: {
      locale: 'en',
      fallbackLocale: 'en',
      localeDir: 'locales',
      enableInSFC: true
    }
  }
};
