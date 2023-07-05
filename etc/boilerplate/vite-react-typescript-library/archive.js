const adm_zip = require('adm-zip');
const zip = new adm_zip(undefined, undefined);

zip.addLocalFolder('./pages', undefined);
zip.addLocalFolder('./dist', undefined);
zip.addLocalFolder('./package.json', undefined);
zip.addLocalFolder('./tailwind.plugin.osomui.js', undefined);
zip.addLocalFolder('./LICENSE', undefined);
zip.addLocalFolder('./README.md', undefined);

zip.writeZip('archive.zip', undefined);
