// Dependencies
import MFH from 'make-fetch-happen';
import logSymbols from 'log-symbols';
import { renderFile } from 'ejs';
import { sha256 } from 'hash-wasm';
import { stable } from './data/versions.mjs';
import { writeFile, symlink } from 'fs/promises';
import path from 'path';

const fetch = MFH.defaults({
  cacheManager: '.cache'
});

const __dirname = path.resolve(path.dirname(''));

// via https://codeburst.io/javascript-async-await-with-foreach-b6ba62bbf404
async function asyncForEach(array, callback) {
  for (let index = 0; index < array.length; index++) {
    await callback(array[index], index, array);
  }
}

async function getHash(blob) {
  const data = new Uint8Array(blob);
  const checksum = await sha256(data);

  return checksum;
}

async function template(outFile, data) {
  data.classPrefix = (outFile.startsWith('Aliases/')) ? 'Nsis' : 'Makensis';

  renderFile(path.join(__dirname, `cmd/data/nsis@${data.versionMajor}.ejs`), data, async (err, contents) => {
    if (err) {
      console.error(logSymbols.error, err);
      return;
    }

    await writeFile(outFile, contents);

    console.log(logSymbols.success, `Saved: ${outFile}`);
  });
}

const createManifest = async (version) => {
  let data = {};

  data.version = version;
  data.versionMajor = version[0];
  data.versionNoDot = version.replace(/\./g, '');
  data.directory = (/\d(a|b|rc)\d*$/.test(data.version) === true) ? `NSIS%20${data.versionMajor}%20Pre-release` : `NSIS%20${data.versionMajor}`;

  const zipUrl = `https://downloads.sourceforge.net/project/nsis/${data.directory}/${data.version}/nsis-${data.version}.zip`;
  const bzUrl = `https://downloads.sourceforge.net/project/nsis/${data.directory}/${data.version}/nsis-${data.version}-src.tar.bz2`;

  try {
    const responseZip = await fetch(zipUrl);
    data.hashZip = await getHash(await responseZip.arrayBuffer());

    const responseBzip = await fetch(bzUrl);
    data.hashBzip2 = await getHash(await responseBzip.arrayBuffer());

    await template(`Formula/makensis@${data.version}.rb`, data);
  } catch(error) {
    if (error.statusMessage) {
      if (error.statusMessage === 'Too Many Requests') {
        return console.warn(logSymbols.warning, `${error.statusMessage}: nsis-${version}.zip`);
      }
      return console.error(logSymbols.error, `${error.statusMessage}: nsis-${version}.zip`);
    } else if (error.code === 'ENOENT') {
      return console.log('Skipping Test: Manifest Not Found');
    }

    console.error(logSymbols.error, error);
  }

  try {
    await symlink(`../Formula/makensis@${data.version}.rb`, `Aliases/nsis@${data.version}.rb`);
    console.log(logSymbols.success, `Saved: Aliases/nsis@${data.version}.rb`);
  } catch (error) {
    console.error(logSymbols.warning, `Skipping: Aliases/nsis@${data.version}.rb`);
  }
};

const allVersions = [...stable.v2, ...stable.v3];

// All versions
asyncForEach(allVersions, async key => {
  const value = stable[key];
  await createManifest(key, value);
});
