import React from 'react';

import DarkModeButton from './DarkModeButton';
import GameResultIcon from '../../components/GameResultIcon';
import LanguagePicker from '../../components/LanguagePicker';
import OnlineIndicator from './OnlineIndicator';
import UserName from '../../components/User/UserName';
import VimModeButton from './VimModeButton';
import GameActionButtons from '../../components/GameActionButtons';

const ModeButtons = ({ player }) => (
  <div
    className="btn-group align-items-center mr-auto"
    role="group"
    aria-label="Editor mode"
  >
    <VimModeButton player={player} />
    <DarkModeButton player={player} />
  </div>
);

const EditorToolbar = ({
  type,
  player,
  editor,
  toolbarClassNames,
  editorSettingClassNames,
  userInfoClassNames,
  langPickerStatus,
  actionBtnsProps,
  showControlBtns,
}) => (
  <>
    <div data-player-type={type}>
      <div className={toolbarClassNames} role="toolbar">
        <div
          className={editorSettingClassNames}
          role="group"
          aria-label="Editor settings"
        >
          <LanguagePicker editor={editor} status={langPickerStatus} />
        </div>

        {showControlBtns && (
          <>
            <ModeButtons player={player} />
            <GameActionButtons {...actionBtnsProps} />
          </>
        )}

        <div className={userInfoClassNames} role="group" aria-label="User info">
          <UserName user={player} />
          <OnlineIndicator player={player} />
        </div>
      </div>
    </div>

    <div
      className="position-absolute"
      style={{
 bottom: '5%', right: '5%', opacity: '0.5', zIndex: '100',
}}
    >
      <GameResultIcon editor={editor} />
    </div>
  </>
);

export default EditorToolbar;
