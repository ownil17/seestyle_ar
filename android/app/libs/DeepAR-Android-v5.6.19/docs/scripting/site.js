const DEEPAR_SDK_VERSION = 'v5.6.19';

function showOutdatedVersionBanner() {
    let bannerDiv = document.createElement('div');
    bannerDiv.style.backgroundColor = '#e0930d';
    bannerDiv.style.color = '#2f2f2f';
    bannerDiv.style.padding = '8px';
    bannerDiv.innerHTML = 'This version of DeepAR is outdated. Click <a href="https://s3.eu-west-1.amazonaws.com/sdk.developer.deepar.ai/doc/scripting/index.html" style="color: #010101;">here</a> to open the documentation of the latest DeepAR version.';
    document.body.prepend(bannerDiv);
}

fetch('https://api.developer.deepar.ai/downloads').then(async function(response) {
    let responseJson = await response.json();
    let sdkDownloadsJson = responseJson['sdkDownloads'];
    for (let i = 0; i < sdkDownloadsJson.length; ++i) {
        let sdkDownloadJson = sdkDownloadsJson[i];
        let latestStableJson = sdkDownloadJson['latestStable'];
        for (let j = 0; j < latestStableJson.length; ++j) {
            let versionJson = latestStableJson[j];
            if (versionJson['type'] == 'rel') {
                if (('v' + versionJson['version']) != DEEPAR_SDK_VERSION) {
                    showOutdatedVersionBanner();
                }
                return;
            }
        }
    }
    showOutdatedVersionBanner();
    console.log('Failed to discover the latest DeepAR version info.');
}).catch(function() {
    console.log('Failed to fetch the latest DeepAR version info.');
});
