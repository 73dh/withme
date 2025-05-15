String shortenedText(String originalText) =>
    originalText.length > 16
        ? '${originalText.substring(0, 16)}...'
        : originalText;

String shortNameText(String originalText) =>
    originalText.length > 3
        ? '${originalText.substring(0, 3)}..'
        : originalText;
