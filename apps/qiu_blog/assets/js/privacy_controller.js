const commentsAllowed =
  () => localStorage.getItem("commentsAllowed") == "true";

const toggleComments = (event) => {
  if (event.target.id != "toggle_comments") {
    return;
  }

  event.preventDefault();

  localStorage.setItem("commentsAllowed", !commentsAllowed());
  render();
}

const render = () => {
  const commentsInfoEl = document.querySelector("#comments_info");
  if (commentsInfoEl != null) {commentsInfoEl.innerHTML = commentsInfo()}

  const disqusThreadEl = document.querySelector("#disqus_thread");
  if (disqusThreadEl != null) {renderDisqusThread(disqusThreadEl)}

  const privacyInfoEl = document.querySelector("#privacy_info");
  if (privacyInfoEl != null) {privacyInfoEl.innerHTML = privacyInfo()};

  document.addEventListener('click', toggleComments);
}

const commentsInfo = () => {
  if (commentsAllowed()) {
    return `
    <p>
      The comments are currently enabled. If you wish to disable them, click <a id="toggle_comments" href="#">here</a>.
    </p>
    <p>
      Since comments are managed by <a href="https://disqus.com/" target="_blank">Disqus</a>, disabling them won't erase
      any of your previously stored personal data. If you wish to do that, please refer to
      <a href="https://disqus.com/support/">Disqus support</a>.
    </p>
    `
  }

  return `
    <p>
      The comments are currently disabled. If you wish to enable them, click <a id="toggle_comments" href="#">here</a>.
    </p>
    <p>
      The comments are managed by <a href="https://disqus.com/" target="_blank">Disqus</a> which is also the sole
      processor and the controller of your personal data. No private information is collected on this site.
      By enabling the comments you agree to the
      <a href="https://help.disqus.com/terms-and-policies/terms-of-service/" target="_blank">Disqus Terms of Service</a>
      and accept the
      <a href="https://help.disqus.com/terms-and-policies/disqus-privacy-policy" target="_blank">Disqus Privacy Policy</a>.
    </p>
    `
}

const renderDisqusThread = (disqusThreadEl) => {
  if (commentsAllowed()) {
    (function() {
      var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
      dsq.id = "disqus-loader";
      dsq.src = '//' + window.disqus_shortname + '.disqus.com/embed.js';
      (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
  }
  else {
    disqusThreadEl.innerHTML = "";
  }
}

const privacyInfo = () => {
  if (commentsAllowed()) {
    return `
    <p>
      According to your settings, the comments are currently enabled.
      If you wish to disable them, click <a id="toggle_comments" href="#">here</a>.
      Since comments are managed by <a href="https://disqus.com/" target="_blank">Disqus</a>, disabling them won't erase
      any of your previously stored personal data. If you wish to do that, please refer to
      <a href="https://disqus.com/support/">Disqus support</a>.
    </p>
    `
  }
  else {
    return `
    <p>
      According to your settings, the comments are currently disabled.
      If you wish to enable them, click <a id="toggle_comments" href="#">here</a>. By enabling the comments you
      agree to the <a href="https://help.disqus.com/terms-and-policies/terms-of-service/" target="_blank">Disqus Terms of Service</a>
      and accept the <a href="https://help.disqus.com/terms-and-policies/disqus-privacy-policy" target="_blank">Disqus Privacy Policy</a>.
    </p>
    `
  }
}

render()
