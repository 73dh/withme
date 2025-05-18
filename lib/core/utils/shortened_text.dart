String shortenedText(String originalText) =>
    originalText.length > 16
        ? '${originalText.substring(0, 16)}...'
        : originalText;

String shortenedNameText(String originalText, {int length=3}) =>
    originalText.length > length
        ? '${originalText.substring(0, length)}..'
        : originalText;
