String shortenedText(String originalText) =>
    originalText.length > 16
        ? '${originalText.substring(0, 16)}...'
        : originalText;
