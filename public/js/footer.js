(function () {
  document.querySelectorAll('.footer__crypto-method').forEach(function (button) {
    button.addEventListener('click', function () {
      var address = button.dataset.address;
      if (!address || !navigator.clipboard) return;

      navigator.clipboard.writeText(address).then(function () {
        button.classList.add('footer__crypto-method--copied');
        button.title = 'Copied!';
        setTimeout(function () {
          button.classList.remove('footer__crypto-method--copied');
          button.title = 'Click to copy';
        }, 1500);
      });
    });
  });
})();
