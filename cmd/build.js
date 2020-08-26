// Dependencies
const download = require('download');
const ejs = require('ejs');
const hasha = require('hasha');
const symbol = require('log-symbols');
const { join } = require('path');
const versions = require('./data/versions.json');
const fs = require('fs').promises;

// via https://codeburst.io/javascript-async-await-with-foreach-b6ba62bbf404
async function asyncForEach(array, callback) {
  for (let index = 0; index < array.length; index++) {
    await callback(array[index], index, array);
  }
}

function getHash(blob) {
  const hash = hasha(blob, {algorithm: 'sha256'});

  return hash;
}

async function template(outFile, data) {
  data.classPrefix = (outFile.startsWith('Aliases/')) ? 'Nsis' : 'Makensis';

  ejs.renderFile(join(__dirname, `/data/nsis@${data.versionMajor}.ejs`), data, async (err, contents) => {
    if (err) {
      console.error(symbol.error, err);
      return;
    }

    await fs.writeFile(outFile, contents, (err) => {
      if (err) throw err;
      console.log(symbol.success, `Saved: ${outFile}`);
    });
  });
}

const createManifest = async (version) => {
  let data = {};
  let blob;

  data.version = version;
  data.versionMajor = version[0];
  data.versionNoDot = version.replace(/\./g, '');
  data.directory = (/\d(a|b|rc)\d*$/.test(data.version) === true) ? `NSIS%20${data.versionMajor}%20Pre-release` : `NSIS%20${data.versionMajor}`;

  const zipUrl = `https://downloads.sourceforge.net/project/nsis/${data.directory}/${data.version}/nsis-${data.version}.zip`;
  const bzUrl = `https://downloads.sourceforge.net/project/nsis/${data.directory}/${data.version}/nsis-${data.version}-src.tar.bz2`;

  try {
    blob = await download(zipUrl);
    data.hashZip = getHash(blob);

    blob = await download(bzUrl);
    data.hashBzip2 = getHash(blob);

    await template(`Formula/makensis@${data.version}.rb`, data);
    await fs.symlink(`Formula/makensis@${data.version}.rb`,`Aliases/nsis@${data.version}.rb`);
  } catch(error) {
    if (error.statusMessage) {
      if (error.statusMessage === 'Too Many Requests') {
        return console.warn(symbol.warning, `${error.statusMessage}: nsis-${version}.zip`);
      }
      return console.error(symbol.error, `${error.statusMessage}: nsis-${version}.zip`);
    } else if (error.code === 'ENOENT') {
      return console.log('Skipping Test: Manifest Not Found');
    }

    console.error(symbol.error, error);
  }
};

const allVersions = [...versions.stable.v2, ...versions.stable.v3];

// All versions
asyncForEach(allVersions, async key => {
  const value = versions.stable[key];
  await createManifest(key, value);
});
