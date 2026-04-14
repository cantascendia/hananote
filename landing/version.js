/* HanaNote Landing Page — Dynamic version from CDN */
(function () {
  var CDN = 'https://cdn.hrtyaku.com/hananote/version.json';
  var GH = 'https://github.com/cantascendia/hananote/releases/latest';

  fetch(CDN)
    .then(function (r) { return r.json(); })
    .then(function (d) {
      var url = d.url || GH;
      var ver = d.version || '';
      var size = d.size ? (d.size / 1048576).toFixed(1) + ' MB' : '';

      document.querySelectorAll('#download-cta, #download-main').forEach(function (a) {
        a.href = url;
      });

      var info = document.getElementById('version-info');
      if (info && ver) info.textContent = 'v' + ver + (size ? ' \u00B7 ' + size : '');

      var meta = document.getElementById('download-meta');
      if (meta && ver) meta.textContent = 'v' + ver + (size ? ' \u00B7 ' + size : '');
    })
    .catch(function () {
      document.querySelectorAll('#download-cta, #download-main').forEach(function (a) {
        a.href = GH;
      });
    });
})();
