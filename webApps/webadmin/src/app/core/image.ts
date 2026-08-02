/** Skalerer telefonfotos ned til samme grænse og kvalitet som iOS-admin. */
export async function prepareJpeg(file: File, maxPixels = 2048): Promise<Blob> {
  const bitmap = await createImageBitmap(file, { imageOrientation: 'from-image' });
  const scale = Math.min(1, maxPixels / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  const context = canvas.getContext('2d');
  if (!context) throw new Error('Browseren kunne ikke behandle billedet.');
  context.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  bitmap.close();
  return await new Promise<Blob>((resolve, reject) =>
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error('Billedet kunne ikke gøres til JPEG.'))),
      'image/jpeg',
      0.85,
    ),
  );
}
